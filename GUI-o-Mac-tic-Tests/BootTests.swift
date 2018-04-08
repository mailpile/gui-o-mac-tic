import XCTest
@testable import GUI_o_Mac_tic

class BootTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_booting_with_example_config_throws_no_exceptions() {
        let boot = Boot()
        XCTAssertNoThrow(try boot.boot())
    }
    
    func test_booting_with_empty_config_throws() throws {
        func configProvider() throws -> [String] {
            return [String]()
        }
        let boot = Boot()
        XCTAssertThrowsError(try boot.boot(configProvider)) { (error) -> Void in
            XCTAssertTrue((error as? BootError)! == BootError.emptyStage1)
        }
    }
    
    func test_booting_with_example_config_provides_stage_1() {
        let boot = Boot()
        try? boot.boot()
        XCTAssertTrue(String.isNeitherNilNorEmpty(boot.stage1))
    }
    
    func test_booting_with_missing_stage1_throws() {
        func configProvider() throws -> [String] {
            var config = [String]()
            config.append("OK GO")
            return config
        }
        let boot = Boot()
        XCTAssertThrowsError(try boot.boot(configProvider)) { (error) -> Void in
            XCTAssertTrue((error as? BootError)! == BootError.emptyStage1)
        }
    }
    
    func test_booting_with_example_config_provides_stage_2() {
        let boot = Boot()
        try? boot.boot()
        XCTAssertFalse(boot.stage2.isEmpty)
    }
    
    func test_booting_with_missing_stage2_throws() {
        func configProvider() throws -> [String] {
            var config = [String]()
            config.append("This string will only be loaded, it won't be parsed.")
            return config
        }
        XCTAssertThrowsError(try Boot().boot(configProvider)) { (error) -> Void in
            XCTAssertTrue((error as? BootError)! == BootError.emptyStage2)
        }
    }
}
