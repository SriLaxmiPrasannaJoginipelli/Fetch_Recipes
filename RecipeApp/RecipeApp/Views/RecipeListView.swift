//
//  RecipeListView.swift
//  RecipeApp
//
//  Created by Srilu Rao on 4/17/25.
//

import SwiftUI

struct RecipeListView: View {
    @EnvironmentObject private var viewModel : RecipeViewModel
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                } else if viewModel.isEmptyState {
                    emptyStateView
                } else {
                    recipeList
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    refreshButton
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error occurred")
            }
            .onChange(of: viewModel.errorMessage) { error in
                showErrorAlert = (error != nil)
            }
            .task {
                await viewModel.fetchRecipes()
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var recipeList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.recipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeCard(recipe: recipe)
                            .transition(.opacity.combined(with: .scale))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    private var refreshButton: some View {
        Button {
            Task {
                await viewModel.fetchRecipes()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.headline)
                .foregroundColor(.pink)
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .padding(.bottom, 8)
            Text("No recipes available")
                .font(.title2)
            Text("Pull to refresh or try again later")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .foregroundColor(.white)
    }
}





