import XCTest

class Caronae_UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTakeScreenshots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        
        snapshot("0_SignIn")
        
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let suaIdentificaOAquiTextField = elementsQuery.textFields["Sua identificação aqui"]
        suaIdentificaOAquiTextField.tap()
        suaIdentificaOAquiTextField.typeText("12345678910")
        
        let suaChaveAquiTextField = elementsQuery.textFields["Sua chave aqui"]
        suaChaveAquiTextField.tap()
        suaChaveAquiTextField.typeText("ABC123")
        elementsQuery.buttons["ACESSAR"].tap()
        
        addUIInterruptionMonitor(withDescription: "Allow push", handler: { (alert) -> Bool in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
            }
            return true
        })
        
        snapshot("1_AllRides")
        
        app.tables.cells.element(boundBy: 0).tap()
        
        snapshot("3_Ride")
        
//        app.scrollViews.otherElements.images["Profile Picture"].tap()
//        snapshot("5_Profile")
//        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tabBars.buttons["Minhas"].tap()
        
        snapshot("4_MyRides")
        
        app.navigationBars["Minhas"].children(matching: .button).element.tap()
        
        snapshot("2_CreateRide")
    }
    
}
