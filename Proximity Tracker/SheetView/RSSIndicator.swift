//
//  RSSIndicator.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI // Import the SwiftUI framework for UI components

// View to display RSSI (signal strength) as a bar indicator
struct SmallRSSIIndicator: View { // Defines a custom SwiftUI View for the signal strength (RSSI) indicator
    
    @Environment(\.colorScheme) var colorScheme // Access current color scheme (light or dark mode) for adaptive styling
    let rssi: Double // Current RSSI value (signal strength in dBm) provided to this view
    let bestRSSI: Double // Strongest expected RSSI (used as 100% signal reference)
    
    var body: some View { // Body defines the view's UI layout
        
        let quality: Int = Int(floor(4 * rssiToPercentage(rssi: rssi, bestRSSI: bestRSSI))) // Calculate signal quality level (0-4) from RSSI relative to bestRSSI
        
        let size: CGFloat = 15 // Base size (in points) for the indicator (controls bar height & spacing)
        
        HStack(spacing: size/10) { // Horizontal stack to arrange bars side by side with given spacing
            
            let minHeight = 0.4 // Minimum height factor (fraction of full size) for the smallest bar
            let step = (1-minHeight)/4 // Height increment factor for each subsequent bar (from minHeight to max)
            
            ForEach(0..<4, id: \.self) { index in // Iterate over 4 indices (0 to 3) to create each signal bar
                
                let active = quality >= index && rssi > Constants.worstRSSI // Determine if this bar is active (signal at or above this level and RSSI valid)
                
                SmallRSSIIndicatorLine(height: size * (minHeight + step*Double(index)), size: size) // Create a bar view with height proportional to its index (taller for higher index)
                    .opacity(active ? 1 : 0.5) // Full opacity if active, otherwise dimmed to 50%
                    .animation(.easeInOut, value: active) // Animate the opacity change smoothly when active state changes
            }
            
        }
        .offset(y: -size * 0.1) // Slightly adjust vertical position upwards for better alignment
        .frame(height: size) // Fix the total height of the indicator to the base size
        .foregroundColor(Color.accentColor.opacity(colorScheme.isLight ? 0.8 : 1)) // Apply accent color to bars (slightly transparent in light mode for contrast)
    }
}

// Subview (SwiftUI View) representing a single RSSI bar segment
struct SmallRSSIIndicatorLine: View { // Subview that draws one bar of the RSSI indicator
    
    let height: CGFloat // Height of this bar (in points)
    let size: CGFloat // Base size from parent (used for width and corner radius)
    
    var body: some View { // Defines the content (shape) of this bar view
        
            RoundedRectangle(cornerRadius: size/3) // Rounded rectangle shape to represent the bar (corner radius based on size)
            .frame(width: size/4, height: height) // Set the rectangle's width to size/4 and height to the specified height
            .frame(height: size, alignment: .bottom) // Place the rectangle in a frame of total height `size`, aligned to bottom
    }
}

// Preview provider for Xcode Canvas (shows an example of SmallRSSIIndicator)
struct Previews_RSSIIndicator_Previews: PreviewProvider { // Conforms to PreviewProvider for SwiftUI preview
    static var previews: some View { // Previews property providing a view for the canvas
        SmallRSSIIndicator(rssi: -100, bestRSSI: -30) // Example usage of SmallRSSIIndicator with sample RSSI values
    }
}
