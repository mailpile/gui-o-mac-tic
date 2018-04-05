import XCTest
@testable import GUI_o_Mac_tic
class GUI_o_Mac_ticTests: XCTestCase {
    func testInit() {
        let validURL = URL(string: "http://example.org")!
        let command = ShowURL(url: validURL)
        XCTAssert(command.url == validURL, "Incorrect init.")
    }
}
