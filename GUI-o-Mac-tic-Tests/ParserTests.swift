import XCTest
@testable import GUI_o_Mac_tic

class ParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_throws_on_empty_config() {
        XCTAssertThrowsError(try Parser.parse(json: "")) { (error) -> Void in
            XCTAssertEqual(error as? ParsingError, ParsingError.empty)
        }
    }
    
    func test_throws_on_nonJSON_input() {
        XCTAssertThrowsError(try Parser.parse(json: "foobar")) { (error) -> Void in
        XCTAssertEqual(error as? ParsingError, ParsingError.notJSON)
        }
    }
    
    func test_throws_on_empty_json() {
        XCTAssertThrowsError(try Parser.parse(json: "{}")) { (error) -> Void in
            XCTAssertEqual(error as? ParsingError, ParsingError.nonCompliantInput)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
