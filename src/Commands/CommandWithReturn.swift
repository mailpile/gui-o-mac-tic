import Foundation

protocol CommandWithReturn {
    func execute(executedSuccessfully: inout Bool)
}
