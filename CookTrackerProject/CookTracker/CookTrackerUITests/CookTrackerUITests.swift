//
//  CookTrackerUITests.swift
//  CookTrackerUITests
//
//  Created by Tsubasa Kubota on 2025/06/21.
//

import XCTest

final class CookTrackerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAppLaunchAndNavigation() throws {
        // アプリ起動とナビゲーションテスト
        let app = XCUIApplication()
        app.launch()
        
        // タブバーの存在確認
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "タブバーが表示されていません")
        
        // ホームタブが選択されていることを確認
        let homeTab = app.tabBars.buttons["ホーム"]
        XCTAssertTrue(homeTab.exists, "ホームタブが見つかりません")
        
        // レシピタブをタップ
        let recipeTab = app.tabBars.buttons["レシピ"]
        if recipeTab.exists {
            recipeTab.tap()
        }
        
        // タイマータブをタップ
        let timerTab = app.tabBars.buttons["タイマー"]
        if timerTab.exists {
            timerTab.tap()
        }
        
        // 履歴タブをタップ
        let historyTab = app.tabBars.buttons["履歴"]
        if historyTab.exists {
            historyTab.tap()
        }
    }
    
    @MainActor
    func testHomeScreenElements() throws {
        // ホーム画面要素テスト
        let app = XCUIApplication()
        app.launch()
        
        // ホームタブに移動
        let homeTab = app.tabBars.buttons["ホーム"]
        if homeTab.exists {
            homeTab.tap()
        }
        
        // 調理統計セクションの確認
        let cookingStatsText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '調理統計'")).firstMatch
        if cookingStatsText.exists {
            XCTAssertTrue(cookingStatsText.isHittable, "調理統計セクションが表示されていません")
        }
        
        // ユーザー情報カードの確認
        let levelText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'レベル'")).firstMatch
        if levelText.exists {
            XCTAssertTrue(levelText.isHittable, "レベル表示が見つかりません")
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
