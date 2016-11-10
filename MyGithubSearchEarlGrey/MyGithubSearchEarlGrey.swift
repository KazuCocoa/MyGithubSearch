import XCTest

class MyGithubSearchEarlGrey: XCTestCase {

    let eg: EarlGreyImpl = EarlGrey()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // See more example: https://github.com/google/EarlGrey/tree/master/Tests/FunctionalTests/Sources
    func testExample() {
        // Can identify value with "grey_accessibilityValue"
        eg.selectElement(with: grey_accessibilityValue("Search"))
            .assert(with: grey_sufficientlyVisible())

        // see if you would like to know keyboar handling
        // https://github.com/google/EarlGrey/blob/master/Tests/FunctionalTests/Sources/FTRKeyboardKeysTest.m
        // You can check the target is value/accessibilityIdentifier/accessibilityLabel and so on via inspector provided by iOS
        // new line "\n" is "resutn" of keyboard
        eg.selectElement(with: grey_accessibilityValue("Search"))
            .perform(grey_tap())
            .perform(grey_typeText("KazuCocoa\n"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
