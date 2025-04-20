//
//  RecipeServiceProtocol.swift
//  RecipeApp
//
//  Created by Srilu Rao on 4/17/25.
//

import Foundation

protocol RecipeServiceProtocol {
    func fetchRecipes(from url: URL) async throws -> [Recipe]
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case networkError(URLError)
    case unknown(Error)
}

class RecipeService: RecipeServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    
    func fetchRecipes(from url: URL) async throws -> [Recipe] {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try JSONDecoder().decode(RecipeResponse.self, from: data).recipes
            } catch {
                throw NetworkError.decodingError
            }
        case 400...499:
            throw NetworkError.invalidResponse
        case 500...599:
            throw NetworkError.networkError(URLError(.badServerResponse))
        default:
            throw NetworkError.invalidResponse
        }
    }
}
