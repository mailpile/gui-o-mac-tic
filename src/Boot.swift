import Foundation

class Boot {
    private (set) public var part1: String? = nil
    private (set) public var part2 = [String]()
    
    func boot() {
        let process = Process()
        process.launchPath = "/bin/sh"
        
        let url = Bundle.main.url(forResource: "configurator", withExtension: "sh")
        process.arguments = url?.relativePath.components(separatedBy: .whitespaces)
        
        let stdout = Pipe()
        let stdoutHandle = stdout.fileHandleForReading
        process.standardOutput = stdout
        
        let stderr = Pipe()
        let stderrHandle = stderr.fileHandleForReading
        process.standardError = stderr
        
        process.launch()
        process.waitUntilExit()
        
        let stderrData = stderrHandle.readDataToEndOfFile()
        stderrHandle.closeFile()
        
        let stdoutData = stdoutHandle.readDataToEndOfFile()
        stdoutHandle.closeFile()
        
        guard process.terminationStatus == EX_OK, stderrData.isEmpty else {
            let stderrOutput = NSString(data: stderrData, encoding: String.Encoding.utf8.rawValue) ?? "unknown error"
            NSLog("Failed to obtain configuration. Error: \(stderrOutput)")
            exit(EX_USAGE)
        }
        
        let stdoutOutput = NSString(data: stdoutData, encoding: String.Encoding.utf8.rawValue)
        let lines = stdoutOutput?.components(separatedBy: .newlines)
        
        guard lines?.isEmpty == false else {
            NSLog("Error: the config input is empty.")
            exit(EX_USAGE)
        }
        
        var part1 = String()
        var part2 = [String]()
        
        var inPart2 = false
        for line in lines! {
            guard line.count != 0 else {
                continue
            }
            
            if !inPart2 {
                inPart2 = line.hasPrefix("OK ") && (line.hasPrefix("OK GO") || line.hasPrefix("OK LISTEN"))
                if inPart2 && line.hasPrefix("OK GO") {
                    break
                }
            }
            if inPart2 {
                part2.append(line)
            } else {
                part1.append(line)
            }
        }
        self.part1 = part1
        self.part2 = part2
    }
}
