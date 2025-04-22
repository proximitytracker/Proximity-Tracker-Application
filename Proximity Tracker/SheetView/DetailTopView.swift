//
//  DetailTopView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

struct DetailTopView: View {
    // Top section of the tracker detail, showing name and connection info
    
    @ObservedObject var tracker: BaseDevice    // The tracker device data
    @ObservedObject var bluetoothData: BluetoothTempData    // Bluetooth data (advertisement/RSSI) for this tracker
    @ObservedObject var clock = Clock.sharedInstance    // Shared clock to get current time
    let notCurrentlyReachable: Bool    // Indicates if the device is currently unreachable
    
    var body: some View {
        
        VStack {
            HStack {
                Text(tracker.getName)    // Display the tracker's name
                    .bold()    // Bold font
                    .font(.largeTitle)    // Large title font size for name
                    .lineLimit(1)    // Only allow one line for name
                    .foregroundColor(Color("MainColor"))    // Use the app's main color for the name text
                    .minimumScaleFactor(0.8)    // Allow text to scale down to 80% if needed to fit

                Spacer()
            }
            .padding(.horizontal)
            .padding(.horizontal, 5)
            .padding(.bottom, 2)
            
            if let lastSeenSeconds = getLastSeenSeconds(device: tracker, currentDate: clock.currentDate) {
                
                let connectionStatus = tracker.getType.constants.connectionStatus(advertisementData: bluetoothData.advertisementData_publisher)    // Determine connection status from advertisement data
                
                VStack(spacing: 2) {    // Stack connection status texts with minimal spacing
                    if notCurrentlyReachable {    // If device is not reachable
                        Text("no_connection".localized())    // Show "No Connection" text
                            .bold()    // Bold text
                            .foregroundColor(.accentColor)    // Accent color text for no connection
                            .frame(maxWidth: .infinity, alignment: .leading)    // Extend text to full width, left-aligned
                    } else {    // If the device is reachable
                        if connectionStatus != .Unknown {    // If a specific connection status is available
                            Text(connectionStatus.description.localized())    // Show the connection status (e.g., Connected/Disconnected)
                                .bold()    // Bold font
                                // .foregroundColor(connectionStatus == .OwnerDisconnected ? .red : connectionStatus == .OwnerConnected ? .green : formHeaderColor)    // (Optional color styling, currently commented out)
                                .frame(maxWidth: .infinity, alignment: .leading)    // Extend text to full width, left-aligned
                        }
                    }
                    
                    Text("last_seen".localized() + ": \(getSimpleSecondsText(seconds: lastSeenSeconds))")    // Show how long ago the tracker was last seen
                        .bold()    // Bold font
                        // .foregroundColor(formHeaderColor)    // (Optional color styling for text, commented out)
                        .frame(maxWidth: .infinity, alignment: .leading)    // Extend text to full width, left-aligned
                }
                .padding(.horizontal)
                .padding(.horizontal, 5)
            }
        }
    }
}

struct Previews_TrackerTopView_Previews: PreviewProvider {
    static var previews: some View {
        
        let vc = PersistenceController.sharedInstance.container.viewContext
        
        let device = BaseDevice(context: vc)
        device.setType(type: .Tile)
        device.firstSeen = Date()
        device.lastSeen = Date()
        
        let detectionEvent = DetectionEvent(context: vc)
        
        detectionEvent.time = device.lastSeen
        detectionEvent.baseDevice = device
        
        let location = Location(context: vc)
        
        location.latitude = 52
        location.longitude = 8
        location.accuracy = 1
        
        detectionEvent.location = location
        
        try? vc.save()
        
        return NavigationView {
            TrackerDetailView(tracker: device, bluetoothData: BluetoothTempData(identifier: UUID().uuidString))
                .environment(\.managedObjectContext, vc)
        }
    }
}
