//  CustomLabel.swift (Proximity Tracker app) 
//  Created by user238598 on 4/2/24.

import SwiftUI

struct SettingsLabel: View {
    // A horizontal label with an icon and text, for use in setting lists or forms
    let imageName: String // SF Symbols icon name to display on the left
    let text: String // The text to display next to the icon
    var backgroundColor: Color = Color.blue // Background color for the icon circle (default blue)
    
    @Environment(\.colorScheme) private var colorScheme // Current color scheme (light/dark), can be used for styling
    @Environment(\.isEnabled) private var isEnabled: Bool // Environment flag indicating if this view is enabled
    
    var body: some View {
        HStack {
            SettingsIcon(imageName: imageName, backgroundColor: backgroundColor)
            // Icon view on the left with specified image and background color
            Text(text.localized())
                .foregroundColor(Color("MainColor")) // Use the app's main color for the text
                .multilineTextAlignment(.leading) // Align text to the leading edge, allow multiline
            Spacer()
            // Spacer pushes the text to the leading side and fills remaining space
        }
        .frame(height: Constants.SettingsLabelHeight) // Fixed height for the label row (defined in Constants)
        .frame(maxWidth: .infinity) // Expand to fill the horizontal space available
        .contentShape(Rectangle()) // Make the entire row tappable by using a rectangular shape
        .opacity(isEnabled ? 1 : 0.5) // If disabled, reduce opacity to 50%; full opacity if enabled
    }
}

struct CustomPickerLabel: View {
    // A label view that shows a description with an icon and a selected value on the right
    let selection: String // The currently selected value text to display on the right side
    var backgroundColor = Color.blue // Background color for the icon circle (default blue)
    let description: String // Description text for this setting option (displayed next to icon)
    let imageName: String // SF Symbols icon name for the setting's icon
    
    @Environment(\.isEnabled) private var isEnabled: Bool // Environment flag indicating if interaction is enabled
    
    var body: some View {
        HStack {
            SettingsLabel(imageName: imageName, text: description, backgroundColor: self.backgroundColor)
            // Reuse SettingsLabel to show the icon and description text
            Spacer()
            Text(selection.localized())
                .foregroundColor(.gray) // Show the selected value in gray text
                .animation(nil) // Disable implicit animation when the selection text changes
                .opacity(isEnabled ? 1 : 0.5) // Dim the text if this view is disabled
        }
    }
}

struct NavigationLinkLabel: View {
    // A label view similar to SettingsLabel, with optional status text and navigation indicator
    let imageName: String // SF Symbols icon name for the leading icon
    let text: String // The main text label to display
    var backgroundColor: Color // Background color for the icon circle (default blue if not specified)
    var isNavLink: Bool // Indicates if this label is a navigation link (true) or an external link (false)
    let status: String // Optional status text to show on the trailing side (empty string if none)
    
    @Environment(\.isEnabled) private var isEnabled: Bool // Environment flag for enabled/disabled state
    
    init(imageName: String, text: String, backgroundColor: Color = Color.blue, isNavLink: Bool = true, status: String = "") {
        // Initialize the label with defaults for background color, link type, and status text
        self.imageName = imageName
        self.text = text
        self.backgroundColor = backgroundColor
        self.isNavLink = isNavLink
        self.status = status
    }
    
    var body: some View {
        HStack {
            SettingsLabel(imageName: imageName, text: text, backgroundColor: backgroundColor)
            // Leading icon and text using SettingsLabel
            Spacer()
            
            if (status != "") {
                Text(status.localized())
                    .foregroundColor(.gray) // Status text in gray
                    .opacity(isEnabled ? 1 : 0.5) // Dim status text if view is disabled
            }
            
            if (isNavLink) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray) // Chevron icon in gray (indicates navigation link)
                    .opacity(isEnabled ? 1 : 0.5) // Dim icon if view is disabled
            } else {
                Image(systemName: "link")
                    .foregroundColor(.gray) // Link icon in gray (indicates external link)
                    .opacity(isEnabled ? 1 : 0.5) // Dim icon if view is disabled
            }
        }
    }
}

struct SettingsIcon: View {
    // A reusable icon view: a white symbol on a colored circular background
    let imageName: String // Name of the SF Symbol image to display inside the circle
    let backgroundColor: Color // Background fill color for the circle
    let size: CGFloat = 30 // Diameter of the circle (and the base size for the icon)
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(backgroundColor) // Draw the circle with the given background color
            Image(systemName: imageName)
                .font(.system(size: size / 2, weight: .bold)) // Use a font to set icon size to half of circle's diameter, bold weight
                .foregroundColor(.white) // Icon symbol in white color for contrast
                .clipped() // Ensure the image is clipped to its bounding frame (safety measure)
        }
        .frame(width: size, height: size) // Set the overall size of the icon view (width and height of the circle)
        .padding(.trailing, 5) // Add spacing to the trailing side of the icon (spacing from following content)
        .compositingGroup() // Render the circle and icon together as one group (helps if applying effects)
    }
}
