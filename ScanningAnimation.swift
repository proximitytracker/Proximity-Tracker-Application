//
//  ScanningAnimation.swift
//  Promixity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

// A view that creates an animated scanning effect.
struct ScanAnimation: View {
    
    @State var rotation = false       // State variable to control rotation animation.
    let size: CGFloat                 // The overall size (width and height) of the scanning animation.
    
    @State var withBackground = false // Flag to determine if a background gradient should be applied.
    
    var body: some View {
        
        ZStack {
            
            // Determine an alternative color based on the withBackground flag.
            let altColor = withBackground ?
                Color(#colorLiteral(red: 0.1862959564, green: 0.5486807823, blue: 0.8759589791, alpha: 1))
                : Color.accentColor
            
            // Create an angular gradient which will be masked to a circular shape.
            AngularGradient(gradient: Gradient(colors: withBackground ? [.white.opacity(0.1), .white] : [.white, altColor]),
                            center: .center)
                .mask(Circle())
            
                // Overlay additional circles to enhance the scanning effect.
                .overlay(ZStack {
                    
                    let smallerSize = size * 0.15 // Calculate a size for the inner circles.
                    
                    // Draw a circular stroke with a partially transparent white color.
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: size * 0.7, height: size * 0.7)
                    
                    // Calculate a size for the white border circle.
                    let whiteBorderSize = smallerSize + size * 0.1
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: whiteBorderSize, height: whiteBorderSize)
                    
                    // Draw the central circle with the alternative color.
                    Circle()
                        .foregroundColor(altColor)
                        .frame(width: smallerSize, height: smallerSize)
                })
            
                // Apply a rotation effect:
                // If rotation is true, rotate a full circle; if withBackground is true, start from -65 degrees.
                .rotationEffect(Angle(degrees: rotation ? 360 : (withBackground ? -65 : 0)), anchor: .center)
                // Animate the rotation continuously with a linear animation.
                .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: rotation)
                .onAppear {
                    // Toggle the rotation state on appear to start the animation.
                    // The async call works around a known SwiftUI bug.
                    DispatchQueue.main.async {
                        rotation = !withBackground
                    }
                }
        }
        .frame(width: size, height: size)               // Set the frame of the view based on the given size.
        .padding(withBackground ? size * 0.2 : 0)          // Apply padding if a background is enabled.
        .background(
            // If withBackground is true, apply a linear gradient; otherwise, use a clear background.
            LinearGradient(colors: withBackground ? [
                Color(#colorLiteral(red: 0.008081560023, green: 0.5630413294, blue: 0.9129524827, alpha: 1)),
                Color(#colorLiteral(red: 0.2278856039, green: 0.3596727252, blue: 0.7548273206, alpha: 1))
            ] : [.clear],
            startPoint: .top,
            endPoint: .bottom)
        )
        .compositingGroup()  // Ensures proper layering of view effects.
    }
}

// MARK: - Preview Provider
struct Previews_ScanningAnimation_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with a size of 250 and background enabled.
        ScanAnimation(size: 250, withBackground: true)
    }
}
