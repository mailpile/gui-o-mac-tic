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
    
    // MARK: Tests for argument to c-style argument parser.
    
    func test_empty_argument_empty_cstyle_argument() throws {
        let cstyleArgs = try Parser.parse(arguments: "")
        XCTAssertTrue(cstyleArgs.isEmpty)
    }
    
    func test_single_argument_single_cstyle_argument() throws {
        let cstyleArgs = try Parser.parse(arguments: "test")
        XCTAssert(cstyleArgs.first == "test", "Expected 'test', received \(cstyleArgs.first ?? "nil")")
    }
    
    func test_space_results_in_multiple_arguments() throws {
        var args = [String]()
        args.append("testA")
        args.append("testB")
        args.append("testC")
        let cstyleArgs = try Parser.parse(arguments: "\(args[0]) \(args[1]) \(args[2])")
        
        XCTAssertTrue(args.count == cstyleArgs.count)
        XCTAssertTrue(args == cstyleArgs)
    }
    
    func test_space_results_in_multiple_arguments_unless_quoted() throws {
        var args = [String]()
        args.append("testA")
        args.append("\"this is test B\"") // Quoted string, shall parse as a single c-style argument.
        args.append("testC")
        let cstyleArgs = try Parser.parse(arguments: "\(args[0]) \(args[1]) \(args[2])")
        
        XCTAssertTrue(args.count == cstyleArgs.count)
        XCTAssertTrue(args == cstyleArgs)
    }
    
    func test_unclosed_quotationmark_throws() {
        XCTAssertThrowsError(try Parser.parse(arguments: "\"unclosed quotation mark test")) { (error) -> Void in
            XCTAssertEqual(error as? ParsingError, ParsingError.unclosedQuote)
        }
    }
    
    func test_unclosed_quotationmark_within_quotationsmarks_throws() {
        XCTAssertThrowsError(try Parser.parse(arguments: "\"unclosed quotation \" mark test\"")) { (error) -> Void in
            XCTAssertEqual(error as? ParsingError, ParsingError.unclosedQuote)
        }
    }
    
}
