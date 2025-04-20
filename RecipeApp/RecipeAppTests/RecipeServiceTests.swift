//
//  RecipeServiceTests.swift
//  RecipeAppTests
//
//  Created by Srilu Rao on 4/17/25.
//

import XCTest
import Compression
@testable import RecipeApp

final class RecipeServiceTests: XCTestCase {
    private var recipeService: RecipeService!
    private var mockSession: MockURLSession!
    private let testURL = URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ")!
    
    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        let session = URLSession(configuration: config)
        recipeService = RecipeService(session: session)

        // Clear previous stubs
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.stubResponse = nil
        MockURLProtocol.stubError = nil
    }


    
    // MARK: - Success Tests
    
    func testFetchRecipesSuccess() async throws {
        let jsonData = """
        {
            "recipes": [
                {
                    "cuisine": "Italian",
                    "name": "Pasta",
                    "photo_url_small": "https://example.com/small.jpg",
                    "photo_url_large": "https://example.com/large.jpg",
                    "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6"
                }
            ]
        }
        """.data(using: .utf8)!

        MockURLProtocol.stubResponseData = jsonData
        MockURLProtocol.stubResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        let recipes = try await recipeService.fetchRecipes(from: testURL)

        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.name, "Pasta")
    }


    
    // MARK: - Failure Tests
    
    func testFetchRecipesInvalidResponse() async {
        // Given
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: testURL,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.stubResponseData = Data() // Optional, if your service handles data + bad status

        // When/Then
        do {
            _ = try await recipeService.fetchRecipes(from: testURL)
            XCTFail("Expected to throw error")
        } catch {
            XCTAssertTrue(error is NetworkError, "Expected NetworkError but got \(error)")
        }
    }

    
    func testFetchRecipesMalformedData() async {
        // Given
        let malformedData = """
        {
            "recipes": [
                {
                    "name": "Pasta",
                    "photo_url_small": "https://example.com/small.jpg",
                    "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6"
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.stubResponseData = malformedData
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: testURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When/Then
        do {
            _ = try await recipeService.fetchRecipes(from: testURL)
            XCTFail("Expected to throw error")
        } catch {
            XCTAssertTrue(error is NetworkError, "Expected NetworkError but got \(error)")
        }
    }

    
    func testFetchRecipesEmptyData() async throws {
        let emptyData = "{\"recipes\": []}".data(using: .utf8)!
        MockURLProtocol.stubResponseData = emptyData
        MockURLProtocol.stubResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        let recipes = try await recipeService.fetchRecipes(from: testURL)
        XCTAssertTrue(recipes.isEmpty)
    }


    
    func testFetchRecipesNetworkError() async {
        MockURLProtocol.stubError = URLError(.notConnectedToInternet)

        do {
            _ = try await recipeService.fetchRecipes(from: testURL)
            XCTFail("Expected to throw error")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

}
