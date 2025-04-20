//
//  Extensions.swift
//  RecipeApp
//
//  Created by Srilu Rao on 4/17/25.
//

import Foundation
import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}
