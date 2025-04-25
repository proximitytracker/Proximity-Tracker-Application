//
//  TrackingHistoryView.swift
//  Promixity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

// A view to display a history list of tracked devices (older than the manual scan buffer).
struct TrackerHistoryView: View {
    
    @ObservedObject var clock = Clock.sharedInstance  // Shared clock instance for dynamic time updates.
    
    // Fetch devices that were last seen before the manual scanning time window.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BaseDevice.lastSeen, ascending: false)],
        predicate: NSPredicate(format: "lastSeen < %@ AND deviceType != %@ AND deviceType != nil",
                               Clock.sharedInstance.currentDate.addingTimeInterval(-Constants.manualScanBufferTime) as CVarArg,
                               DeviceType.Unknown.rawValue),
        animation: .spring())
    private var devices: FetchedResults<BaseDevice>
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                
                // Iterate through each device in the fetched results.
                ForEach(devices) { elem in
                    
                    // If the device has detection events and a valid "last seen" time, display its info.
                    if let detectionEvents = elem.detectionEvents,
                       let lastSeenSeconds = getLastSeenSeconds(device: elem, currentDate: clock.currentDate) {
                        
                        let times = detectionEvents.count  // Count the detection events.
                        // Create a header text showing how many times the device was seen and when it was last seen.
                        let timesText = String(format: "seen_x_times_last".localized(),
                                               times.description,
                                               getSimpleSecondsText(seconds: lastSeenSeconds, longerDate: false))
                        
                        // Display a custom section with the device entry button.
                        CustomSection(header: timesText) {
                            DeviceEntryButton(device: elem, showAlerts: true)
                        }
                    }
                }
                 
                // If no devices are found, display a placeholder view with an informative symbol and message.
                if(devices.count == 0) {
                    BigSymbolViewWithText(title: "",
                                          symbol: "questionmark.circle.fill",
                                          subtitle: "no_device_detected_yet")
                }
                
                Spacer() // Add extra space at the bottom.
                
            }
            .frame(maxWidth: Constants.maxWidth)
            .frame(maxWidth: .infinity)
            .padding(.bottom)
        }
        .modifier(CustomFormBackground()) // Apply a custom background style.
        .navigationTitle("tracker_history") // Set the navigation bar title.
        // .modifier(GoToRootModifier(view: .ManualScan)) // Optional: reset navigation stack (currently commented out).
    }
}

// MARK: - Preview Provider
struct Previews_OldTrackersView_Previews: PreviewProvider {
    
    static var previews: some View {
        TrackerHistoryView()
    }
}

