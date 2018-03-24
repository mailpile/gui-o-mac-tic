import Foundation

final class Shell {
    private init() {
    }
    
    @discardableResult
    static func execute(_ args: [String]) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}
