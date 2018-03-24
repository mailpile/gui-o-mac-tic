import XCTest
@testable import Mailpile

class MailpileTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJSONToObjects() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var config:Config!
        if let data = NSData.init(contentsOfFile: "/Users/petur/Desktop/mailpile.conf.json  ") {
            if let json = try? JSONSerialization.jsonObject(with: data as Data, options: []) as? [String: Any] {
                config = Config.init(json: json!)
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
