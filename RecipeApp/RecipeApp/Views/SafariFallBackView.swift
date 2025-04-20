//
//  SafariFallBackView.swift
//  RecipeApp
//
//  Created by Srilu Rao on 4/18/25.
//

import SwiftUI

struct SafariFallbackView: View {
    let url: URL

    var body: some View {
        VStack(spacing: 20) {
            ProgressView("Opening in Safari…")
                .onAppear {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }

            Text("Redirecting to Safari…")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
