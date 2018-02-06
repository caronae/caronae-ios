import XCTest
import SimulatorStatusMagic

class Caronae_UITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SDStatusBarManager.sharedInstance().timeString = "09:41"
        SDStatusBarManager.sharedInstance().enableOverrides()
        
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
        SDStatusBarManager.sharedInstance().disableOverrides()
    }
    
    func testTakeScreenshots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let elementsQuery = app.scrollViews.otherElements
        
        let suaIdentificaOAquiTextField = elementsQuery.textFields["Sua identificação aqui"]

        if !suaIdentificaOAquiTextField.exists {
            app.tabBars.buttons["Menu"].tap()
            elementsQuery.buttons["Meu perfil"].tap()
            elementsQuery.buttons["ButtonSignout"].tap()
            app.collectionViews.cells["Sair"].tap()
        }

        snapshot("0_SignIn")

        suaIdentificaOAquiTextField.tap()
        suaIdentificaOAquiTextField.typeText("12345678910")
        
        let suaChaveAquiTextField = elementsQuery.textFields["Sua chave aqui"]
        suaChaveAquiTextField.tap()
        suaChaveAquiTextField.typeText("ABC123")
        elementsQuery.buttons["ACESSAR"].tap()
        
        _ = app.tables.cells.element(boundBy: 0).waitForExistence(timeout: 10)
        app.tables.cells.element(boundBy: 0).tap()
        
        snapshot("3_Ride")
        
//        elementsQuery.images["Profile Picture"].tap()
//        snapshot("5_Profile")
//        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        snapshot("1_AllRides")
        
        app.tabBars.buttons["Minhas"].tap()
        
        snapshot("4_MyRides")
        
        app.navigationBars["Minhas"].children(matching: .button).element.tap()
        
        fillCreateRide()

        app.swipeDown()
        
        snapshot("2_CreateRide")
    }
    
    func fillCreateRide() {
        let app = XCUIApplication()
        let elementsQuery = app.scrollViews.otherElements
        
        elementsQuery.buttons["Bairro"].tap()
        app.tables.staticTexts["Zona Sul"].tap()
        app.tables.staticTexts["Botafogo"].tap()

        let referenceTextField = elementsQuery.textFields["Referência Ex: Shopping Tijuca"]
        referenceTextField.tap()
        referenceTextField.typeText("Samaritano")

        let routeTextField = elementsQuery.textFields["Rota Ex: Maracanã, Leopoldina, Linha Vermelha"]
        routeTextField.tap()
        routeTextField.typeText("Túnel Santa Barbara, Linha Vermelha")

        elementsQuery.buttons["Centro Universitário"].tap()
        app.tables.staticTexts["Cidade Universitária"].tap()
        app.tables.staticTexts["CCMN"].tap()
        
        app.swipeUp()
        
        let increaseSlotsButton = elementsQuery.steppers.buttons.element(boundBy: 1)
        increaseSlotsButton.tap()
        increaseSlotsButton.tap()
        
        let descriptionTextView = elementsQuery.textViews["notes"]
        descriptionTextView.tap()
        descriptionTextView.typeText("Podemos combinar algum outro caminho.")
        
        elementsQuery.buttons["Ter"].tap()
        elementsQuery.buttons["Qui"].tap()
        
        elementsQuery.buttons["date"].tap()
        let pickerWheelsQuery = app.datePickers.pickerWheels
        pickerWheelsQuery.element(boundBy: 1).adjust(toPickerWheelValue: "08")
        pickerWheelsQuery.element(boundBy: 2).adjust(toPickerWheelValue: "00")
        app.toolbars.buttons["OK"].tap()
    }
}
