//
//  TrackerDetailView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI
import CoreBluetooth
import MapKit

struct TrackerDetailView: View {
    // View showing detailed information for a tracker device
    
    @ObservedObject var tracker: BaseDevice    // The tracker device model observed for changes
    @ObservedObject var bluetoothData: BluetoothTempData    // Observes Bluetooth scanning data (RSSI, advertisement) for the tracker
    @StateObject var soundManager = SoundManager()    // Manages playing sounds (e.g., finding sound) for the tracker
    @ObservedObject var clock = Clock.sharedInstance    // Shared clock object to get current time for calculations
    
    let persistenceController = PersistenceController.sharedInstance    // Persistence (Core Data) controller instance for data storage
    
    var body: some View {
        
        // Calculated here for animation
        // Determine if the device is currently unreachable (e.g., not seen recently)
        let notCurrentlyReachable = deviceNotCurrentlyReachable(device: tracker, currentDate: clock.currentDate)    // Compute reachability based on current time and device's last seen time
        
        NavigationSubView(spacing: Constants.SettingsSectionSpacing) {    // Navigation-style container with consistent section spacing
            
            DetailTopView(tracker: tracker, bluetoothData: bluetoothData, notCurrentlyReachable: notCurrentlyReachable)    // Top section with device name and connection status
            
            DetailMapView(tracker: tracker)    // Map section showing recent locations of the device
            
            
            
            DetailGeneralView(tracker: tracker, soundManager: soundManager)    // General actions (find, observe, ignore) section
            
            DetailNotificationsView(tracker: tracker)    // Notifications section (recent alerts/alarms)
            
            DetailMoreView(tracker: tracker)    // More options (NFC scan, support website)
            DetailDebugView(tracker: tracker, bluetoothData: bluetoothData)    // Debug info section (only shown in debug mode)
        }
        .animation(.spring(), value: tracker.ignore)    // Animate changes when tracker's ignore status toggles
        .animation(.spring(), value: notCurrentlyReachable)    // Animate changes when device reachability changes
        .navigationBarTitleDisplayMode(.inline)    // Use inline style for the navigation bar title
    }
}

struct Previews_TrackerDetailView_Previews: PreviewProvider {
    // Preview provider for SwiftUI canvas
    static var previews: some View {
        
        let vc = PersistenceController.sharedInstance.container.viewContext    // Obtain a Core Data view context for preview
        
        let device = BaseDevice(context: vc)    // Create a sample BaseDevice object
        device.setType(type: .Tile)    // Set the sample device's type (e.g., Tile tracker)
        device.firstSeen = Date()    // Set the first seen time to now for preview
        device.lastSeen = Date()    // Set the last seen time to now for preview
        
        let detectionEvent = DetectionEvent(context: vc)    // Create a sample detection event
        
        detectionEvent.time = device.lastSeen    // Set the detection event time to the device's last seen time
        detectionEvent.baseDevice = device    // Link the detection event to the device
        
        let location = Location(context: vc)    // Create a sample location
        
        location.latitude = 52    // Example latitude for preview
        location.longitude = 8    // Example longitude for preview
        location.accuracy = 1    // Example accuracy for preview
        
        detectionEvent.location = location    // Attach the location to the detection event
        
        try? vc.save()    // Save the context (though not strictly necessary for preview)
        
        return NavigationView {    // Show the tracker detail inside a NavigationView for the preview
            TrackerDetailView(tracker: device, bluetoothData: BluetoothTempData(identifier: UUID().uuidString))    // The TrackerDetailView with the sample device and a dummy Bluetooth data
                .environment(\.managedObjectContext, vc)    // Inject the managed object context into the view environment
        }
    }
}
