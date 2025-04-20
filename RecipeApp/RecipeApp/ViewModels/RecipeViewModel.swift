//
//  RecipeViewModel.swift
//  RecipeApp
//
//  Created by Srilu Rao on 4/17/25.
//

import Foundation
import SwiftUI
import os.log

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isEmptyState = false
    
    private let recipeService: RecipeServiceProtocol
    private let imageLoader: ImageLoader
    private let logger = Logger(subsystem: "com.RecipeApp.recipe", category: "ViewModel")
    
    init(recipeService: RecipeServiceProtocol = RecipeService(),
         imageLoader: ImageLoader = ImageLoader.shared) {
        self.recipeService = recipeService
        self.imageLoader = imageLoader
    }
    
    func fetchRecipes(from url: URL = Constants.recipesURL) async {
        isLoading = true
        errorMessage = nil
        isEmptyState = false
        
        do {
            let fetchedRecipes = try await recipeService.fetchRecipes(from: url)
            
            if fetchedRecipes.isEmpty {
                isEmptyState = true
                logger.info("Fetched empty recipes list")
            } else {
                recipes = fetchedRecipes
                logger.debug("Successfully fetched \(fetchedRecipes.count) recipes")
            }
        } catch {
            errorMessage = error.localizedDescription
            recipes = []
            logger.error("Failed to fetch recipes: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func loadImage(
        for recipe: Recipe,
        targetSize: CGSize? = nil,
        highQuality: Bool = true,
        applySharpening: Bool = true
    ) async -> UIImage? {
        let urlString: String?
        
        if highQuality {
            // Priority order: large -> small
            urlString = recipe.photoURLLarge ?? recipe.photoURLSmall
        } else {
            // Use explicitly requested size
            urlString = targetSize?.width ?? 0 >= 600 ? recipe.photoURLLarge : recipe.photoURLSmall
        }
        
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            logger.debug("No valid URL found for recipe \(recipe.id)")
            return nil
        }
        
        do {
            let image = try await imageLoader.loadImage(
                url: url,
                recipeId: recipe.id.uuidString,
                targetSize: targetSize
            )
            
            if applySharpening, let image = image, targetSize != nil {
                logger.debug("Applying sharpening to image for recipe \(recipe.id)")
                return image.applyingSharpening()
            }
            return image
        } catch {
            logger.error("Failed to load image for recipe \(recipe.id): \(error.localizedDescription)")
            return nil
        }
    }
    
    // Convenience method for card views
    func loadCardImage(for recipe: Recipe) async -> UIImage? {
        await loadImage(
            for: recipe,
            targetSize: CGSize(width: 400, height: 400),
            highQuality: true,
            applySharpening: true
        )
    }
    
    // Convenience method for detail views
    func loadDetailImage(for recipe: Recipe) async -> UIImage? {
        await loadImage(
            for: recipe,
            targetSize: CGSize(width: 800, height: 800),
            highQuality: true,
            applySharpening: false
        )
    }
}

extension RecipeViewModel {
    enum Constants {
        static let recipesURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
        static let malformedURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!
        static let emptyURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!
    }
    
    enum ImageSize {
        case card
        case detail
        
        var targetSize: CGSize {
            switch self {
            case .card: return CGSize(width: 400, height: 400)
            case .detail: return CGSize(width: 800, height: 800)
            }
        }
    }
}
