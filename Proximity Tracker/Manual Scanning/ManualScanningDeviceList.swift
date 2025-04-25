//
//  ManualScanningDeviceList.swift
//  Promixity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

// A view representing a section of tracker devices with an optional help button.
struct TrackerSection: View {
    let trackers: [BaseDevice] // Array of tracker devices to be displayed.
    let header: String         // Header title for the section.
    let showHelp: Bool         // Flag to determine whether a help button should be shown.
    @State var showAlert = false  // State to control the display of an alert.
    
    var body: some View {
        
        // If help is enabled, create a button that shows an alert when tapped.
        let helpView = showHelp ?
        AnyView(Button(action: { showAlert = true }, label: {
            HStack(spacing: 5) {
                Text("safe_trackers")
                Image(systemName: "questionmark.circle")
            }
            .offset(x: -10) // Slight left offset to adjust positioning.
        }))
        : AnyView(EmptyView()) // Otherwise, use an empty view.
        
        // Use a custom section view that accepts a header and an extra header view.
        CustomSection(header: header, headerExtraView: helpView) {
            // Iterate over each tracker and display a device entry button.
            ForEach(trackers) { device in
                DeviceEntryButton(device: device, showAlerts: true)
                    .padding(.vertical, 1)
                
                // Insert a custom divider between items, except after the last one.
                if device != trackers.last {
                    CustomDivider()
                }
            }
        }
        .frame(maxWidth: Constants.maxWidth) // Limit the width of the section.
        
        // Show an alert with a title and description when showAlert becomes true.
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("safe_trackers_header"),
                  message: Text("safe_trackers_description"))
        })
    }
}

// A button view representing a device entry that triggers navigation to a detailed view.
struct DeviceEntryButton: View {
    
    @ObservedObject var device: BaseDevice   // The device represented by this button.
    @ObservedObject private var settings = Settings.sharedInstance  // Shared settings instance.
    
    @State private var showLoading = false  // State flag for showing a loading indicator.
    @State var showAlerts: Bool = false     // State flag to control alert icon display.
    
    var body: some View {
        
        // Button action that opens a detail view (sheet) for the selected device.
        Button {
            // Immediately start a short loading animation.
            withAnimation(.easeInOut(duration: 0.001)) {
                showLoading = true
            }
            
            // After a short delay, attempt to open the device detail sheet.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                openSheet(withDevice: device)
            }
            
            // If the sheet didn't open quickly, try again after a slightly longer delay.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if !settings.showSheet {
                    openSheet(withDevice: device)
                }
            }
            
        } label: {
            // The content of the button is the DeviceListEntryView that displays device info.
            DeviceListEntryView(device: device,
                                bluetoothData: BluetoothManager.sharedInstance.getBluetoothData(bluetoothID: device.currentBluetoothId ?? ""),
                                showAlerts: showAlerts,
                                showLoading: showLoading)
        }
        .foregroundColor(.primary) // Set the text and image color to the primary color.
        .buttonStyle(PlainButtonStyle()) // Remove default button styling.
        
        // Listen for changes in the sheet display state to stop the loading indicator.
        .onChange(of: settings.showSheet) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showLoading = false
                    }
                }
            }
        }
    }
}

// Function to open the tracker detail sheet by setting the selected device in settings.
func openSheet(withDevice: BaseDevice) {
    let settings = Settings.sharedInstance
    settings.selectedTracker = withDevice  // Save the selected device.
    settings.showSheet = true              // Trigger the display of the detail sheet.
}
