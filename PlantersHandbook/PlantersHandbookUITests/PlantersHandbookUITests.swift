//
//  PlantersHandbookUITests.swift
//  PlantersHandbookUITests
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import XCTest
import PlantersHandbook

typealias CompletionHandler = (_ success:Bool) -> Void

/* === Developer Personally Tested (Test cases do not exist)===
 All View Controllers:
    - Buttons lead to appopraite view controllers or actions
    - Any writing/reading to/from database is working
    - Duplicate Season, Block, SubBlock, Cache titles, and duplicate HandbookEntry dates are not approved and app gives feedback on duplicate
 
 *** Anything out of the ordinary for tests is explained below ***
 
 Splash View:
    - Animation does not continously loop foreveer
    - Users get sent to appropraite view controller
        - If user is not logged in -> Welcome View Controller
        - else -> HomeTabViewController
 SignUpViewController:
    - Error handling for incorrect input on email. password, and confirm password is working and gives feedback
 LoginViewController:
    - Error handling for incorrect input on email. password is working and gives feedback
 TallySheetViewController:
    - Error handling for incorrect input on bagup, treeType, centPerTreeType, and bundlePerTreeType textfields are working and gives feedback,
    - If user wants to leave while gps is tracking users current path, app prompts user with a confirmation alert
PrintHandbookEntryModalViewController:
    - Any arbartray number of Blocks - SubBlocks - Caches with any sort of content (none, some, alot) in any way is displayed properly and nothing is cut off
    - The Share Button works and prints all content given in the PrintHandbookEntryModalViewController into a pdf which can be shared using any type of messenger application
 StatisticsViewController:
    - Statistics are displayed properly with no data, some data, and alot of data
    - Moving statistic cards around works fine and stays after user restarts application
    - Statistic card content does not look to crunched up or spread out
    - Statistic card, if containing a season, can change season using SeasonPickerViewController and it updates accordingly
    - Pull to refresh the screen works fine, and any new data in realm updates all statistic cards accordingly
    - Distance and step statistic cards are working
*/

//Super class to all UITest classes for PlantersHandbook
class PlantersHandbookUITests: XCTestCase{
    
    internal var app : XCUIApplication!
    internal let getOneItemPredicate = NSPredicate(format: "exists == 1")
    internal let testUserEmail = "testPlantersHandbook@gmail.com"
    internal let testUserPassword = "TestApp123!"
    
    ///Use this function if you want your test to start with a empty test user
    ///- Parameter testName: The test that is to run
    ///- Parameter completion: Completion handler for this function
    internal func startTestWithEmptyUser(testName: String, completion: @escaping (CompletionHandler)){
        printFromTest(message: "Started: \(testName) with empty user")
        startWithTestUser(){ success in
            if(success){
                let tablesQuery = self.app.tables["Seasons"].cells
                for _ in 0..<tablesQuery.allElementsBoundByAccessibilityElement.count{
                    tablesQuery.element(boundBy: 0).swipeLeft()
                }
                XCTAssertEqual(tablesQuery.allElementsBoundByAccessibilityElement.count, 0)
                completion(success)
            }else{
                completion(false)
            }
        }
    }
    
    ///Use this function if you want your test to start with a test user
    ///- Parameter completion: Completion handler for this function
    internal func startWithTestUser(completion: @escaping (CompletionHandler)){
        self.app = XCUIApplication()
        self.app.launch()
        
        sleep(5)
        
        if !app.buttons["Login"].exists{
            //Assuming im already logged into test user
            completion(true)
        }else{
            loginTestUser(){ success in
                completion(success)
            }
        }
    }
    
    ///Logs in test user
    ///- Parameter completion: Completion handler for this function
    internal func loginTestUser(completion: @escaping (CompletionHandler)){
        printFromFunction(message: "loginTestUser")
        let loginButton = app.buttons["Login"]
        expectation(for: getOneItemPredicate, evaluatedWith: loginButton, handler: nil)
        waitForExpectations(timeout: 5, handler: {_ in
            loginButton.tap()
            
            let emailTextField = self.app.textFields["email"]
            let passwordTextField = self.app.secureTextFields["password"]
            sleep(2)
            emailTextField.tap()
            emailTextField.typeText(self.testUserEmail)
            passwordTextField.tap()
            passwordTextField.typeText(self.testUserPassword)
            let finalLoginButton = self.app.buttons["Login!"]
            finalLoginButton.tap()
            let logoutButton = self.app.buttons["Logout"]
            self.expectation(for: self.getOneItemPredicate, evaluatedWith: logoutButton, handler: nil)
            self.waitForExpectations(timeout: 7, handler: {_ in
                let HandbookWelcomeAlert = self.app.alerts["Handbook"]
                HandbookWelcomeAlert.buttons["OK"].tap()
                completion(true)
            })
        })
    }
    
    ///If the alert exists get rid of it by pressing "OK"
    ///- Parameter alertIdentifier: Identifer for alert
    internal func getRidOfAlert(alertIdentifier: String){
        if self.app.alerts[alertIdentifier].exists{
            self.app.alerts[alertIdentifier].buttons["OK"].tap()
        }
    }
    
    ///Prints from a function should call this method to print to terminal
    ///- Parameter message: Message to print
    internal func printFromFunction(message: String){
        print("- \(message)")
    }
    
    ///Prints from a test case should call this method to print to terminal
    ///- Parameter message: Message to print
    internal func printFromTest(message: String){
        print("\n\n *** \(message) *** \n\n")
    }
    
}

class BasicTesting: PlantersHandbookUITests {

    ///Logs out of whatever user is currently logged in and logs in the test user
    func testLogin() {
        startTestWithEmptyUser(testName: "testLogoutLogin"){ success in
            XCTAssertTrue(success)
            self.printFromTest(message: "Cleared: testLogoutLogin")
        }
    }
    
    ///Testing The main purpose of this application: Ceation of Season and adding HandbookEntry with Block, SubBlock, and Cache, and then deleting all
    func testFillAndDeletionOFHandbookEntry() {
        startTestWithEmptyUser(testName: "testAddingWaterfall"){ success in
            XCTAssertTrue(success)
            self.app.buttons["Add Season"].tap()
            sleep(1)
            self.app.textFields["SeasonName"].tap()
            self.app.textFields["SeasonName"].typeText("Season 1")
            self.app.buttons["Add"].tap()
            sleep(3)
            self.app.staticTexts["Season 1"].tap()
            sleep(1)
            self.app.buttons["Add Entry"].tap()
            sleep(1)
            self.app.buttons["Add"].tap()
            let tablesQuery = self.app.tables["HandbookEntrys"].cells
            tablesQuery.element(boundBy: 0).tap()
            sleep(1)
            self.getRidOfAlert(alertIdentifier: "Block Manager")
            self.app.buttons["Notes"].tap()
            sleep(1)
            self.app.textViews["NotesTextView"].clearText(andReplaceWith: "I ate some berries")
            self.app.tables.element(boundBy: 0).swipeDown(velocity: .fast)
            sleep(1)
            self.app.buttons["Extra $"].tap()
            sleep(1)
            self.app.textViews["ReasonTextView"].clearText(andReplaceWith: "I built a bridge")
            self.app.textFields["CashTextField"].clearText(andReplaceWith: "10")
            self.app.buttons["Done"].tap()
            self.app.buttons["Add Extra Cash"].tap()
            self.app.tables.element(boundBy: 0).swipeDown(velocity: .fast)
            sleep(1)
            self.app.textFields["BlockName"].tap()
            self.app.textFields["BlockName"].typeText("Block 1")
            self.app.buttons["Add Block"].tap()
            self.app.staticTexts["Block 1"].tap()
            sleep(1)
            self.app.textFields["SubBlockName"].tap()
            self.app.textFields["SubBlockName"].typeText("SubBlock 1")
            self.app.buttons["Add SubBlock"].tap()
            self.app.staticTexts["SubBlock 1"].tap()
            sleep(1)
            self.app.textFields["CacheName"].tap()
            self.app.textFields["CacheName"].typeText("Cache 1")
            self.app.buttons["Add Cache"].tap()
            self.app.staticTexts["Cache 1"].tap()
            sleep(1)
            self.getRidOfAlert(alertIdentifier: "Tally Sheet")
            XCTAssertEqual(self.app.navigationBars.element.identifier, "Cache: Cache 1")
            self.app.navigationBars.buttons.element(boundBy: 0).tap()
            self.app.tables["Caches"].cells.element(boundBy: 0).swipeLeft(velocity: .default)
            self.app.buttons["Delete"].tap()
            XCTAssertEqual(self.app.tables["Caches"].cells.allElementsBoundByAccessibilityElement.count, 0)
            self.app.navigationBars.buttons.element(boundBy: 0).tap()
            sleep(1)
            self.app.tables["SubBlocks"].cells.element(boundBy: 0).swipeLeft(velocity: .default)
            self.app.buttons["Delete"].tap()
            XCTAssertEqual(self.app.tables["SubBlocks"].cells.allElementsBoundByAccessibilityElement.count, 0)
            self.app.navigationBars.buttons.element(boundBy: 0).tap()
            sleep(1)
            self.app.tables["Blocks"].cells.element(boundBy: 0).swipeLeft(velocity: .default)
            self.app.buttons["Delete"].tap()
            XCTAssertEqual(self.app.tables["Blocks"].cells.allElementsBoundByAccessibilityElement.count, 0)
            self.app.navigationBars.buttons.element(boundBy: 0).tap()
            sleep(1)
            self.app.tables["HandbookEntrys"].cells.element(boundBy: 0).swipeLeft(velocity: .default)
            XCTAssertEqual(self.app.tables["HandbookEntrys"].cells.allElementsBoundByAccessibilityElement.count, 0)
            self.app.tables["Seasons"].cells.element(boundBy: 0).swipeLeft(velocity: .default)
            XCTAssertEqual(self.app.tables["Seasons"].cells.allElementsBoundByAccessibilityElement.count, 0)
            
            
            
            self.printFromTest(message: "Cleared: testWaterFall")
        }
    }
    
}

extension XCUIElement {
    ///Source - zysoft https://stackoverflow.com/questions/32821880/ui-test-deleting-text-in-text-field#:~:text=When%20you%20tap%20and%20hold,or%20just%20enter%20new%20text.
    func clearText(andReplaceWith newText:String? = nil) {
        tap()
        tap() //When there is some text, its parts can be selected on the first tap, the second tap clears the selection
        press(forDuration: 1.0)
        let selectAll = XCUIApplication().menuItems["Select All"]
        //For empty fields there will be no "Select All", so we need to check
        if selectAll.waitForExistence(timeout: 0.5), selectAll.exists {
            selectAll.tap()
            typeText(String(XCUIKeyboardKey.delete.rawValue))
        }
        if let newVal = newText { typeText(newVal) }
    }
}
