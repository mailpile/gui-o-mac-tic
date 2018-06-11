import Foundation

/** Errors related to the boot process. */
enum BootError: Error {
    
    /** An error occured while obtaining the config for Stage 1 and 2. */
    case failedToObtainConfig(reason: String)
    
    /** The Stage 1 config was empty. */
    case emptyStage1
    
    /** The Stage 2 config was empty. */
    case emptyStage2
}
