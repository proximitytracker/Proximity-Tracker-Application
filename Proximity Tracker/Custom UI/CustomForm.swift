//  CustomForm.swift (Proximity Tracker app)
//  Created by user238598 on 4/2/24.

import SwiftUI

struct CustomFormBackground: ViewModifier {
    // A view modifier that sets a background color for forms depending on light or dark mode
    @Environment(\.colorScheme) var colorScheme // Current color scheme from the environment
    
    func body(content: Content) -> some View {
        content
            .background(
                colorScheme.isLight 
                    ? Color("FormBackgroundLight").ignoresSafeArea() 
                    : Color.formDeepGray.ignoresSafeArea()
            ) // Apply light background in light mode, or a deep gray background in dark mode (extends to safe area)
    }
}

struct CustomSection: View {
    // A form section view that can contain multiple input views, with optional header and footer
    @Environment(\.colorScheme) var colorScheme // Current color scheme, might be used for styling within the section
    let inputViews: [AnyView] // Array of views that form the content of this section
    var header = "" // Optional header title for the section (default is no header)
    var footer = "" // Optional footer text for the section (default is no footer)
    let headerExtraView: AnyView // An optional extra view to display alongside the header (e.g., an icon or button)
    
    init<V0: View>(
        header: String = "", 
        footer: String = "", 
        headerExtraView: AnyView = AnyView(EmptyView()),
        @ViewBuilder content: @escaping () -> V0
    ) {
        // Initializer for a section containing one view
        let cv = content() 
        // Build the content view from the view builder closure
        inputViews = [AnyView(cv)]
        // Store the single content view in the inputViews array
        self.header = header
        self.footer = footer
        self.headerExtraView = headerExtraView
    }
    
    init<V0: View, V1: View>(
        header: String = "", 
        footer: String = "", 
        headerExtraView: AnyView = AnyView(EmptyView()),
        @ViewBuilder content: @escaping () -> TupleView<(V0, V1)>
    ) {
        // Initializer for a section containing two views
        let cv = content().value
        // Retrieve the tuple of two views from the view builder
        inputViews = [AnyView(cv.0), AnyView(cv.1)]
        // Store both views in the inputViews array
        self.header = header
        self.footer = footer
        self.headerExtraView = headerExtraView
    }
    
    init<V0: View, V1: View, V2: View>(
        header: String = "", 
        footer: String = "", 
        headerExtraView: AnyView = AnyView(EmptyView()),
        @ViewBuilder content: @escaping () -> TupleView<(V0, V1, V2)>
    ) {
        // Initializer for a section containing three views
        let cv = content().value
        // Retrieve the tuple of three views
        inputViews = [AnyView(cv.0), AnyView(cv.1), AnyView(cv.2)]
        // Store the three views in the inputViews array
        self.header = header
        self.footer = footer
        self.headerExtraView = headerExtraView
    }
    
    init<V0: View, V1: View, V2: View, V3: View>(
        header: String = "", 
        footer: String = "", 
        headerExtraView: AnyView = AnyView(EmptyView()),
        @ViewBuilder content: @escaping () -> TupleView<(V0, V1, V2, V3)>
    ) {
        // Initializer for a section containing four views
        let cv = content().value
        // Retrieve the tuple of four views
        inputViews = [AnyView(cv.0), AnyView(cv.1), AnyView(cv.2), AnyView(cv.3)]
        // Store the four views in the inputViews array
        self.header = header
        self.footer = footer
        self.headerExtraView = headerExtraView
    }
    
    init<V0: View, V1: View, V2: View, V3: View, V4: View>(
        header: String = "", 
        footer: String = "", 
        headerExtraView: AnyView = AnyView(EmptyView()),
        @ViewBuilder content: @escaping () -> TupleView<(V0, V1, V2, V3, V4)>
    ) {
        // Initializer for a section containing five views
        let cv = content().value
        // Retrieve the tuple of five views
        inputViews = [AnyView(cv.0), AnyView(cv.1), AnyView(cv.2), AnyView(cv.3), AnyView(cv.4)]
        // Store the five views in the inputViews array
        self.header = header
        self.footer = footer
        self.headerExtraView = headerExtraView
    }
    
    var body: some View {
        VStack {
            if (header != "") {
                // If a header title is provided, display a header view (the actual header view is currently commented out)
                // PlainImageCardGroupHeader(name: header.localized(), extraView: headerExtraView)
            }
            VStack(spacing: 0) {
                ForEach(0 ..< inputViews.count, id: \.self) { index in
                    inputViews[index]
                    // Place each input view in order
                    if (index != inputViews.count - 1) {
                        CustomDivider()
                        // Insert a divider between each pair of views (not after the last one)
                    }
                }
            }
            .modifier(FormModifier()) // Apply form styling (padding and background) to the stacked content
            
            if (footer != "") {
                HStack {
                    Footer(text: footer)
                    // Footer text view at the bottom of the section
                    Spacer()
                }
                .padding(.horizontal, 10) // Add horizontal padding around the footer
            }
        }
        .padding(.horizontal) // Add standard horizontal padding around the entire section
        .padding(.top) // Add standard padding at the top of the section
    }
}

struct Footer: View {
    // A view that displays footer text in a smaller, footnote-style format
    let text: String // The footer text to display
    
    var body: some View {
        Text(text.localized()) // Display the footer text (localized)
            .fixedSize(horizontal: false, vertical: true) // Allow the text to wrap to multiple lines if needed
            .font(.system(.footnote)) // Use the system footnote font for smaller text
            .lineSpacing(2) // Slightly increase line spacing for readability
            .padding(.top, 5) // Add a little padding above the footer text
            .foregroundColor(Color.init(#colorLiteral(red: 0.4768142104, green: 0.4786779284, blue: 0.5020056367, alpha: 1)).opacity(0.9)) // Use a semi-transparent gray color for the text
    }
}

struct CustomDivider: View {
    // A thin gray divider line to separate content
    var body: some View {
        Rectangle()
            .frame(height: 1) // 1 point tall horizontal line
            .foregroundColor(.gray) // Gray color line
            .opacity(0.2) // Make the line semi-transparent
    }
}

struct FormModifier: ViewModifier {
    // A modifier that adds horizontal padding and then applies FormModifierNoPadding for background styling
    func body(content: Content) -> some View {
        content
            .padding(.horizontal) // Add horizontal padding to content
            .modifier(FormModifierNoPadding()) // Apply the form background and shadow styling
    }
}

struct FormModifierNoPadding: ViewModifier {
    // A modifier that applies background, corner radius, and shadow to a form section container
    @Environment(\.colorScheme) var colorScheme // Environment color scheme to decide background color
    let showShadow: Bool // Flag to control whether a shadow is applied
    
    init(showShadow: Bool = true) {
        // Initialize with optional shadow visibility (default true)
        self.showShadow = showShadow
    }
    
    func body(content: Content) -> some View {
        content
            .background(colorScheme.isLight ? Color.white : Color.formGray) // White background for light mode, gray background for dark mode
            .cornerRadius(25) // Rounded corners for the section container
            .compositingGroup() // Create a compositing group for the content (for proper shadow rendering)
            .modifier(ShadowModifier(visible: showShadow)) // Apply shadow if showShadow is true
    }
}

struct ShadowModifier: ViewModifier {
    // A modifier that applies a subtle drop shadow to content if visible
    @Environment(\.colorScheme) var colorScheme // Environment color scheme to adjust shadow based on mode
    let visible: Bool // Flag indicating if the shadow should be visible
    
    init(visible: Bool = true) {
        // Initialize with shadow visibility (default true)
        self.visible = visible
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.gray.opacity(colorScheme.isLight ? 0.15 : 0), 
                radius: visible ? 4 : 0, x: 0, y: 1
            ) // Add a gray shadow (15% opacity in light mode, none in dark mode) with radius 4 if visible, offset 1 point downwards
    }
}

struct Previews_CustomForm_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
        // Preview using a SettingsView (assuming it's defined elsewhere)
    }
}
