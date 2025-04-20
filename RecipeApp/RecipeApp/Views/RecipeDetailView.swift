import SwiftUI
import SafariServices



struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var image: UIImage?
    @State private var showSafariFallback = false
    @State private var safariURL: URL?
    @EnvironmentObject private var viewModel: RecipeViewModel
    
    private enum Constants {
        static let headerHeight: CGFloat = 320
        static let targetSize = CGSize(width: 800, height: 800)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Header Image
                ZStack(alignment: .bottomLeading) {
                    Group {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width)
                                .frame(height: Constants.headerHeight)
                                .clipped()
                        } else {
                            Color(.systemGray5)
                                .frame(height: Constants.headerHeight)
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .tint(.white)
                                )
                        }
                    }
                    
                    LinearGradient(
                        gradient: Gradient(
                            stops: [
                                .init(color: .clear, location: 0.5),
                                .init(color: .black.opacity(0.7), location: 1)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.cuisine)
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text(recipe.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                .frame(height: Constants.headerHeight)
                
                // Action Buttons
                if recipe.sourceURL != nil || recipe.youtubeURL != nil {
                    HStack(spacing: 16) {
                        if let sourceURL = recipe.sourceURL {
                            Button(action: {
                                openInExternalBrowser(urlString: sourceURL)
                            }) {
                                Label("View Recipe", systemImage: "link")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        if let youtubeURL = recipe.youtubeURL {
                            Button(action: {
                                openInExternalBrowser(urlString: youtubeURL)
                            }) {
                                Label("Watch Video", systemImage: "play.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }
                    .padding()
                }
                
                // Recipe Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("About This Recipe")
                        .font(.title2.bold())
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Cuisine")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(recipe.cuisine)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        if let source = recipe.sourceURL {
                            VStack(alignment: .leading) {
                                Text("Source")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(URL(string: source)?.host ?? "Unknown")
                                    .font(.headline)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 10)
                .padding()
            }
        }
        .sheet(isPresented: $showSafariFallback) {
            if let url = safariURL {
                SafariFallbackView(url: url)
            }
        }
        .task {
            image = await viewModel.loadImage(
                for: recipe,
                targetSize: Constants.targetSize,
                highQuality: true
            )
        }
    }
    
    private func openInExternalBrowser(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        safariURL = url
        showSafariFallback = true
        
        // Open in Safari after a small delay to show the loading view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if success {
                    showSafariFallback = false
                }
            })
        }
    }
}

