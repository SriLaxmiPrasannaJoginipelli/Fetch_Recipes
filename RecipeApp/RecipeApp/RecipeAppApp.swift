//
//  RecipeAppApp.swift
//  RecipeApp
//
//  Created by Srilu Rao on 4/17/25.
//

import SwiftUI

@main
struct RecipeAppApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView()
                .environmentObject(RecipeViewModel())
        }
    }
}
