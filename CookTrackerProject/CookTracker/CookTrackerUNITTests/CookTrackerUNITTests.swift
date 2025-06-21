//
//  CookTrackerUNITTests.swift
//  CookTrackerUNITTests
//
//  Created by Tsubasa Kubota on 2025/06/21.
//

import XCTest
@testable import CookTracker
import CoreData

final class CookTrackerUNITTests: XCTestCase {

    var mockPersistenceController: PersistenceController!
    var testContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        // インメモリのCore Dataスタックを作成
        mockPersistenceController = PersistenceController(inMemory: true)
        testContext = mockPersistenceController.container.viewContext
    }
    
    override func tearDown() {
        testContext = nil
        mockPersistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Core Data Tests
    
    func testUserCreation() throws {
        // ユーザー作成テスト
        let user = mockPersistenceController.getOrCreateDefaultUser()
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user.level, 1)
        XCTAssertEqual(user.experiencePoints, 0)
        XCTAssertNotNil(user.id)
    }
    
    func testRecipeCreation() throws {
        // レシピ作成テスト
        let recipe = Recipe(context: testContext)
        recipe.id = UUID()
        recipe.title = "テストレシピ"
        recipe.ingredients = "材料1, 材料2"
        recipe.instructions = "手順1. 手順2."
        recipe.category = "食事"
        recipe.difficulty = 3
        recipe.estimatedTimeInMinutes = 30
        recipe.createdAt = Date()
        recipe.updatedAt = Date()
        
        try testContext.save()
        
        XCTAssertEqual(recipe.title, "テストレシピ")
        XCTAssertEqual(recipe.difficulty, 3)
        XCTAssertEqual(recipe.estimatedTimeInMinutes, 30)
    }
    
    func testCookingRecordCreation() throws {
        // 調理記録作成テスト
        let user = mockPersistenceController.getOrCreateDefaultUser()
        let recipe = Recipe(context: testContext)
        recipe.id = UUID()
        recipe.title = "テストレシピ"
        
        let cookingRecord = CookingRecord(context: testContext)
        cookingRecord.id = UUID()
        cookingRecord.recipe = recipe
        cookingRecord.cookingTimeInMinutes = 25
        cookingRecord.experienceGained = 10
        cookingRecord.cookedAt = Date()
        
        try testContext.save()
        
        XCTAssertEqual(cookingRecord.cookingTimeInMinutes, 25)
        XCTAssertEqual(cookingRecord.experienceGained, 10)
        XCTAssertNotNil(cookingRecord.cookedAt)
    }
    
    // MARK: - Experience Service Tests
    
    func testExperienceCalculation() throws {
        // 経験値計算テスト
        let user = mockPersistenceController.getOrCreateDefaultUser()
        let initialExperience = user.experiencePoints
        
        // 経験値を追加
        user.experiencePoints += 100
        
        XCTAssertEqual(user.experiencePoints, initialExperience + 100)
    }
    
    func testLevelProgression() throws {
        // レベル進行テスト
        let user = mockPersistenceController.getOrCreateDefaultUser()
        
        // 大量の経験値を追加してレベルアップをテスト
        user.experiencePoints = 1000
        
        let expectedLevel = user.calculateLevel()
        XCTAssertGreaterThan(expectedLevel, 1)
    }
    
    // MARK: - Model Extension Tests
    
    func testRecipeExtensions() throws {
        // レシピ拡張メソッドテスト
        let recipe = Recipe(context: testContext)
        recipe.estimatedTimeInMinutes = 45
        
        XCTAssertEqual(recipe.estimatedTimeInMinutes, 45)
    }
    
    func testUserExtensions() throws {
        // ユーザー拡張メソッドテスト
        let user = mockPersistenceController.getOrCreateDefaultUser()
        user.experiencePoints = 250
        
        let progress = user.progressToNextLevel
        XCTAssertGreaterThanOrEqual(progress, 0.0)
        XCTAssertLessThanOrEqual(progress, 1.0)
    }
    
    // MARK: - Performance Tests
    
    func testRecipeSearchPerformance() throws {
        // レシピ検索のパフォーマンステスト
        self.measure {
            // 複数のレシピを作成
            for i in 0..<100 {
                let recipe = Recipe(context: testContext)
                recipe.id = UUID()
                recipe.title = "レシピ\(i)"
                recipe.ingredients = "材料\(i)"
                recipe.category = "食事"
            }
            
            try? testContext.save()
        }
    }
}
