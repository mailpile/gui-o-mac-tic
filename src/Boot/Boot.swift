import Foundation

/**
 Attempts to fetch the config for Stages 1 and 2.
 */
class Boot {
    
    /**
     Provides boot config for Stages 1 and 2
     */
    private class BootConfigProvider {
        /**
         Provides a boot config for Stages 1 and 2 as an ordered list of lines in which the config for Stage 1
         appears before the config for Stage 2.
         
         - Requires: The file configurator.sh to exist in the Resoruces directory.
         - Throws: `BootError.failedToObtainConfig` should configurator.sh not return `EXIT_SUCCESS`.
         - Returns: An ordered list of zero or more lines. If the list is not empty then the config for Stage 1
                    appears before the config of Stage 2.
        */
        static func provideConfig() throws -> [String] {
            let configurator = Bundle.main.url(forResource: "configurator", withExtension: "sh")
            let arguments = configurator?.relativePath.components(separatedBy: CharacterSet(charactersIn: ""))
            let output = try Shell.execute(arguments: arguments)
            guard output.exitStatus == EXIT_SUCCESS else {
                let errorReason = (output.stderr ?? "") + "ErrorCode: (\(output.exitStatus))."
                throw BootError.failedToObtainConfig(reason: errorReason)
            }
            return (output.stdout?.components(separatedBy: .newlines))!
        }
    }
    
    /**
     The config for Stage 1.
     A value of nil indicates that the config is yet to be fetched or fetching it was erroneous.
     */
    private (set) public var stage1: String? = nil
    /**
     The config lines for Stage 2, except the line "OK GO".
     If empty then the config is yet to be fetched or that fetching it was erroneous.
     */
    private (set) public var stage2 = [String]()
    
    typealias configProvider = () throws -> [String]
    /**
     Stores the a boot config for Stages 1 and 2 in, respectivly, `stage1` and `stage2`.
     
     - Throws: `BootError.emptyStage1` on a failiure to fetch a config for Stage 1 and similiarly
               `BootError.emptyStage2` for Stage 2.
     - Postcondition: If no errors are thrown then `stage1` and `stage2` contain the config for Stages 1 and 2.
     */
    func boot(_ configProvider: configProvider = BootConfigProvider.provideConfig) throws {
        let lines = try configProvider()
        
        var stage1 = String()
        var stage2 = [String]()

        var inStage2 = false
        for line in lines {
            // Ignore empty lines.
            guard line.count != 0 else {
                continue
            }
            
            if !inStage2 {
                inStage2 = (line.hasPrefix("OK GO") || line.hasPrefix("OK LISTEN"))
                if inStage2 && line.hasPrefix("OK GO") {
                    break
                }
            }
            if inStage2 {
                stage2.append(line)
            } else {
                stage1.append(line)
            }
        }
        guard !stage1.isEmpty else { throw BootError.emptyStage1 }
        guard inStage2 else { throw BootError.emptyStage2 }
        
        self.stage1 = stage1
        self.stage2 = stage2
    }
}
