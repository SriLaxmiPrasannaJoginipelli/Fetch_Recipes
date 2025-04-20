//
//  ImageLoaderTests.swift
//  RecipeAppTests
//
//  Created by Srilu Rao on 4/17/25.
//

import XCTest
@testable import RecipeApp

@MainActor
final class RecipeAPITests: XCTestCase {
    
    // Test URLs
    let testRecipesURL = URL(string: "https://test.example.com/recipes.json")!
    let testEmptyURL = URL(string: "https://test.example.com/empty.json")!
    let testMalformedURL = URL(string: "https://test.example.com/malformed.json")!
    
    var recipeViewModel: RecipeViewModel!
    var mockRecipeService: MockRecipeService!
    
    override func setUp() {
        super.setUp()
        mockRecipeService = MockRecipeService()
        recipeViewModel = RecipeViewModel(recipeService: mockRecipeService)
    }
    
    override func tearDown() {
        recipeViewModel = nil
        mockRecipeService = nil
        super.tearDown()
    }
    
    // MARK: - Test Helpers
    
    private func createTestRecipe(id: String = "74F6D4EB-DA50-4901-94D1-DEAE2D8AF1D1") -> Recipe {
        return Recipe(
            id: UUID(uuidString: id)!,
            cuisine: "Test Cuisine",
            name: "Test Recipe",
            photoURLSmall: "https://test.com/small.jpg",
            photoURLLarge: "https://test.com/large.jpg",
            sourceURL: "https://test.com/source",
            youtubeURL: "https://youtube.com/watch?v=test"
        )
    }
    
    // MARK: - Test Cases
    
    func testFetchRecipesSuccess() async {
        // Given
        let expectedRecipes = [
            createTestRecipe(id: "74F6D4EB-DA50-4901-94D1-DEAE2D8AF1D1"),
            createTestRecipe(id: "599344F4-3C5C-4CCA-B914-2210E3B3312F")
        ]
        mockRecipeService.mockResults[testRecipesURL] = .success(expectedRecipes)
        
        // When
        await recipeViewModel.fetchRecipes(from: testRecipesURL)
        
        // Then
        XCTAssertFalse(recipeViewModel.isLoading)
        XCTAssertEqual(recipeViewModel.recipes, expectedRecipes)
        XCTAssertNil(recipeViewModel.errorMessage)
        XCTAssertFalse(recipeViewModel.isEmptyState)
    }
    
    func testFetchEmptyRecipes() async {
        // Given
        mockRecipeService.mockResults[testEmptyURL] = .success([])
        
        // When
        await recipeViewModel.fetchRecipes(from: testEmptyURL)
        
        // Then
        XCTAssertFalse(recipeViewModel.isLoading)
        XCTAssertTrue(recipeViewModel.recipes.isEmpty)
        XCTAssertNil(recipeViewModel.errorMessage)
        XCTAssertTrue(recipeViewModel.isEmptyState)
    }
    
    func testFetchRecipesNetworkError() async {
        // Given
        let expectedError = URLError(.notConnectedToInternet)
        mockRecipeService.mockResults[testRecipesURL] = .failure(expectedError)
        
        // When
        await recipeViewModel.fetchRecipes(from: testRecipesURL)
        
        // Then
        XCTAssertFalse(recipeViewModel.isLoading)
        XCTAssertTrue(recipeViewModel.recipes.isEmpty)
        XCTAssertEqual(recipeViewModel.errorMessage, expectedError.localizedDescription)
        XCTAssertFalse(recipeViewModel.isEmptyState)
    }
    
    func testFetchMalformedData() async {
        // Given
        let expectedError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid data"))
        mockRecipeService.mockResults[testMalformedURL] = .failure(expectedError)
        
        // When
        await recipeViewModel.fetchRecipes(from: testMalformedURL)
        
        // Then
        XCTAssertFalse(recipeViewModel.isLoading)
        XCTAssertTrue(recipeViewModel.recipes.isEmpty)
        XCTAssertNotNil(recipeViewModel.errorMessage)
        XCTAssertFalse(recipeViewModel.isEmptyState)
    }
    
    func testLoadingStateDuringFetch() async {
        // Given
        let expectedRecipes = [createTestRecipe()]
        mockRecipeService.mockResults[testRecipesURL] = .success(expectedRecipes)
        mockRecipeService.delay = 0.1
        
        // When
        let task = Task {
            await recipeViewModel.fetchRecipes(from: testRecipesURL)
        }
        
        // Small delay to allow loading state to change
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // Then
        XCTAssertTrue(recipeViewModel.isLoading, "Should be loading during fetch")
        await task.value // Wait for completion
        XCTAssertFalse(recipeViewModel.isLoading, "Should not be loading after completion")
    }
}

// MARK: - Mock RecipeService

class MockRecipeService: RecipeServiceProtocol {
    var mockResults: [URL: Result<[Recipe], Error>] = [:]
    var delay: TimeInterval = 0
    
    func fetchRecipes(from url: URL) async throws -> [Recipe] {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        guard let result = mockResults[url] else {
            throw URLError(.badURL)
        }
        
        switch result {
        case .success(let recipes):
            return recipes
        case .failure(let error):
            throw error
        }
    }
}
