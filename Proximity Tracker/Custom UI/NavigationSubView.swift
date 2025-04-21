//  NavigationSubView.swift (Proximity Tracker app)
//  Created by user238598 on 4/2/24.

import SwiftUI

struct NavigationSubView<Content: View>: View {
    // A container view that provides a scrollable area with custom background for its content
    let content: Content // The content view to be displayed inside this container
    let spacing: CGFloat // The vertical spacing between elements in the content
    
    init(spacing: CGFloat = 0, @ViewBuilder content: () -> Content) {
        // Initialize with an optional spacing and a content view builder
        self.content = content()
        self.spacing = spacing
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            // Scrollable container (vertical) without visible scroll indicators
            VStack(spacing: spacing) {
                // Vertically stack the content with specified spacing
                content
                // Insert the provided content view here
            }
            .padding(.bottom, 30) // Add padding at the bottom for spacing (to avoid content being cut off)
            .frame(maxWidth: Constants.maxWidth) // Constrain content width to a maximum value (for better readability on large screens)
            .frame(maxWidth: .infinity) // Allow the content stack to expand to full width (centers content if narrower than screen)
        }
        .modifier(CustomFormBackground()) // Apply the custom form background to the entire scroll view content
    }
}
