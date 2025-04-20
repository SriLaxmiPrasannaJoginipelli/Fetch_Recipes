//
//  RecipeCard.swift
//  RecipeApp
//
//  Created by Srilu Rao on 4/17/25.
//
import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    @State private var image: UIImage?
    @EnvironmentObject private var viewModel: RecipeViewModel
    
    private enum Constants {
        static let cardHeight: CGFloat = 220
        static let cornerRadius: CGFloat = 16
        static let textPadding: CGFloat = 16
        static let gradientStart: CGFloat = 0.6
        static let targetSize = CGSize(width: 400, height: 400)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Container
            ZStack(alignment: .bottomLeading) {
                // Image Content
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.cardHeight)
                            .clipped()
                    } else {
                        Color(.systemGray5)
                            .frame(height: Constants.cardHeight)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                            )
                    }
                }
                
                // Gradient Overlay
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: .clear, location: Constants.gradientStart),
                            .init(color: .black.opacity(0.7), location: 1)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: Constants.cardHeight)
                
                // Text Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(recipe.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    
                    Text(recipe.cuisine.uppercased())
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .kerning(1.5)
                }
                .padding(Constants.textPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .cornerRadius(Constants.cornerRadius)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
        .task(id: recipe.id) {
            image = await viewModel.loadImage(
                for: recipe,
                targetSize: Constants.targetSize,
                highQuality: true
            )
        }
    }
}
