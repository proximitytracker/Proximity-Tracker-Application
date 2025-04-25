//
//  DeviceListEntryView.swift
//  Promixity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

// A view that represents a single device entry in a list.
struct DeviceListEntryView: View {
    
    // Observed objects to automatically update the view when data changes.
    @ObservedObject var device: BaseDevice                  // The device to display.
    @ObservedObject var bluetoothData: BluetoothTempData      // The temporary Bluetooth data (e.g. signal strength).
    @ObservedObject var clock = Clock.sharedInstance          // Shared clock instance for time-based updates.
    @ObservedObject var settings = Settings.sharedInstance    // Shared settings instance for app-wide configuration.
    @Environment(\.colorScheme) var colorScheme                // Environment property to check light/dark mode.
    
    @State var showAlerts: Bool = false   // State to control whether to show alert icons.
    let showLoading: Bool                 // Flag indicating if a loading indicator should be shown.
    
    var body: some View {
        
        // Retrieve the debug mode flag from settings.
        let debug = settings.debugMode
        
        HStack {
            
            // Display the device type icon with some trailing padding.
            device.getType.constants.iconView
                .padding(.trailing, 3)
            
            // Display the device name with a custom color and vertical padding.
            Text(device.getName)
                .foregroundColor(Color("MainColor"))
                .padding(.vertical)
            
            Spacer() // Push subsequent views to the trailing edge.
            
            // If in debug mode, display first and last seen times for the device.
            if(debug) {
                if let firstSeenSeconds = getFirstSeenSeconds(device: device, currentDate: clock.currentDate),
                   let lastSeenSeconds = getLastSeenSeconds(device: device, currentDate: clock.currentDate) {
                    
                    // Concatenate the two timestamps separated by a bullet.
                    Text("\(firstSeenSeconds)")
                        + Text(" • ")
                        + Text("\(lastSeenSeconds)")
                }
            }
            
            // Optionally show an alert icon if alerts are enabled and there are notifications.
            if showAlerts {
                if let count = device.notifications?.count, count > 0, !device.ignore {
                    Image(systemName: "bell.fill")
                        .frame(width: 23)
                        .foregroundColor(Color.accentColor.opacity(colorScheme.isLight ? 0.8 : 1))
                }
            }
            
            // ZStack to overlay the RSSI indicator and a loading spinner.
            ZStack {
                
                // Display a small RSSI indicator.
                // If the device is not currently reachable, use a worst-case RSSI value.
                SmallRSSIIndicator(rssi: deviceNotCurrentlyReachable(device: device, currentDate: clock.currentDate) ? Constants.worstRSSI : Double(bluetoothData.rssi_publisher), bestRSSI: Double(device.getType.constants.bestRSSI))
                    .opacity(showLoading ? 0 : 1)  // Hide if loading.
                
                // Show a progress view (spinner) if loading.
                ProgressView()
                    .opacity(showLoading ? 1 : 0)
            
            }
            .frame(width: 20) // Set a fixed width for the indicator area.
            
            // Display a chevron to indicate navigation (e.g., tapping leads to details).
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
            
        }
        // Makes the entire HStack tappable.
        .contentShape(Rectangle())
    }
}

// MARK: - Preview Provider
struct Previews_DeviceListEntryView_Previews: PreviewProvider {
    static var previews: some View {
        
        let vc = PersistenceController.sharedInstance.container.viewContext
        
        // Create a dummy device instance for preview purposes.
        let device = BaseDevice(context: vc)
        device.setType(type: .AirTag)
        
        try? vc.save()
        
        // Embed the view in a NavigationView and apply necessary environment settings.
        return NavigationView {
            DeviceListEntryView(device: device,
                                bluetoothData: BluetoothTempData(identifier: UUID().uuidString),
                                showAlerts: true,
                                showLoading: false)
                .environment(\.managedObjectContext, vc)
                .padding()
        }
    }
}
