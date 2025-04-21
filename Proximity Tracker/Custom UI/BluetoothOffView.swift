//  BluetoothOffView.swift (Proximity Tracker app)
//  Created by user238598 on 4/2/24.

import SwiftUI

struct ExclamationmarkView: View {
    // A view that shows a warning icon (exclamation mark inside a triangle)
    var body: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 60, weight: .light, design: .default)) // Use a large SF Symbol icon (size 60, light weight)
            .padding(10) // Add padding around the icon for spacing
    }
}
