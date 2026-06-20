import XCTest

final class CastingFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCastingFlowRevealsCompletedReadingAndAnalysis() throws {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["一事在心"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["缓书其事，静观其变。"].exists)

        let castButton = app.buttons["casting.castButton"]
        XCTAssertTrue(castButton.waitForExistence(timeout: 5))
        XCTAssertTrue(castButton.isHittable)

        castButton.tap()

        XCTAssertTrue(app.staticTexts["卦象已成"].waitForExistence(timeout: 18))
        XCTAssertTrue(app.staticTexts["卦意初读"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab.casting"].exists)

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Casting result UI"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testPrimaryTabsRemainReachableOnLaunch() throws {
        let app = launchApp()

        XCTAssertTrue(app.buttons["tab.casting"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab.history"].exists)
        XCTAssertTrue(app.buttons["tab.settings"].exists)
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-ui-testing"]
        app.launch()
        return app
    }
}
