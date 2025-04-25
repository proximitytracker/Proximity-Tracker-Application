//
//  ManualScanningView.swift
//  Promixity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

// A view that manages manual scanning of devices using Bluetooth, location services, and NFC.
struct ManualScanningView: View {
    
    // Observed objects to keep track of shared settings, Bluetooth state, location, and NFC reader.
    @ObservedObject var settings = Settings.sharedInstance
    @ObservedObject var bluetoothManager = BluetoothManager.sharedInstance
    @ObservedObject var locationManager = LocationManager.sharedInstance
    @ObservedObject var reader = NFCReader.sharedInstance
    
    // Fetch devices from Core Data that have been seen recently (not unknown type).
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BaseDevice.firstSeen, ascending: true)],
        predicate: NSPredicate(format: "lastSeen >= %@ AND deviceType != %@ AND deviceType != nil",
                               Clock.sharedInstance.currentDate.addingTimeInterval(-Constants.manualScanBufferTime) as CVarArg,
                               DeviceType.Unknown.rawValue),
        animation: .spring())
    private var devices: FetchedResults<BaseDevice>
    
    @StateObject var clock = Clock.sharedInstance  // Shared clock instance for time updates.
    
    // Timer that fires every 6 seconds to update waiting hints or refresh the view.
    let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    
    @State var showStillSearchingHint = false  // Toggle to show or hide the "still searching" hint.
    
    /// Constant defining the width and height of the scanning animation.
    private let scanAnimationSize: CGFloat = 72
    
    var body: some View {
        
        NavigationView {
            
            // Filter devices for manual scanning; if the app is in the background, show an empty list.
            let trackers = settings.isBackground ? [] :
            devices.filter({ ($0.lastSeen ?? Date.distantPast) > clock.currentDate.addingTimeInterval(-Constants.manualScanBufferTime) })
            
            let count = trackers.count
            
            NavigationSubView {
                
                let size = scanAnimationSize
                
                // If Bluetooth is turned on, show the scanning animation.
                if bluetoothManager.turnedOn {
                    ScanAnimation(size: size)
                        .padding()
                }
                
                VStack(spacing: 0) {
                    
                    // If Bluetooth is off, show an error view with an exclamation mark and error messages.
                    if !bluetoothManager.turnedOn {
                        ExclamationmarkView()
                            .foregroundColor(.accentColor)
                            .padding(.bottom)
                        
                        VStack(spacing: 10) {
                            Text(getBluetoothProblemHeader())
                                .font(.system(.title))
                            Text(getBluetoothProblemSubHeader())
                                .padding(.horizontal)
                                .lowerOpacity(darkModeAsWell: true)
                        }
                    }
                    else {
                        // Calculate the remaining time before manual scanning wait time expires.
                        let timeRemaining = Int(-clock.currentDate.timeIntervalSince(settings.lastAppStart.addingTimeInterval(60)))
                        
                        ZStack {
                            
                            // Toggle between showing detected tracker count and wait time.
                            let showWaitTime = timeRemaining > 0 && showStillSearchingHint
                            
                            // Display the number of detected trackers.
                            Text(.init(String(format: "we_detected_X_trackers_around_you".localized(),
                                                "\(getBoldString())\(count)",
                                                (count == 1 ? "tracker_singular".localized() : "tracker_plural".localized()) + getBoldString())))
                                .opacity(showWaitTime ? 0 : 1)
                            
                            // Display the wait time if still waiting.
                            Text(.init(String(format: "manual_scanning_wait".localized(),
                                                getBoldString() + timeRemaining.description + "s" + getBoldString())))
                                .opacity(showWaitTime ? 1 : 0)
                        }
                        .opacity(0.9)
                        .padding(.horizontal)
                        // Update the hint visibility based on the timer.
                        .onReceive(timer) { input in
                            if !(timeRemaining > 0 && !settings.isBackground) {
                                withAnimation {
                                    showStillSearchingHint = false
                                }
                            } else {
                                withAnimation {
                                    showStillSearchingHint.toggle()
                                }
                            }
                        }
                    }
                }
                .centered()         // Custom modifier to center the content.
                .lowerOpacity()     // Custom modifier to adjust opacity.
                .padding(.bottom)
                .padding(.top)
                
                VStack(spacing: Constants.SettingsSectionSpacing) {
                    
                    // Separate trackers into those that might be tracking and those considered safe.
                    let mayBeTracking = trackers.filter({ !trackerIsSafe(tracker: $0) })
                    let safeTrackers = trackers.filter({ trackerIsSafe(tracker: $0) })
                    
                    // If there are devices that might be tracking, show them in a section.
                    if mayBeTracking.count > 0 {
                        TrackerSection(trackers: mayBeTracking, header: "", showHelp: false)
                    }
                    
                    // If there are safe devices, show them in a section with a help button.
                    if safeTrackers.count > 0 {
                        TrackerSection(trackers: safeTrackers, header: " ", showHelp: true)
                    }
                    
                    // Optional disclaimer footer (currently commented out).
                    // if(trackers.count > 0) {
                    //     Footer(text: "manual_scan_disclaimer")
                    //         .padding(.horizontal, 10)
                    //         .padding(.horizontal)
                    // }
                }
                
                // Navigation link to show older tracker history.
                NavigationLink(destination: {
                    TrackerHistoryView()
                }, label: {
                    Text("older_trackers".localized() + "...")
                        .centered()
                        .lowerOpacity(darkModeAsWell: true)
                        .padding()
                })
                // Adjust top padding based on whether trackers exist.
                .padding(.top, trackers.count == 0 ? 0 : 10)
            }
            // Apply spring animations for changes in tracker count and tracker list.
            .animation(.spring(), value: count)
            .animation(.spring(), value: trackers)
            .navigationBarTitle("scan")
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use a stack-based navigation view style.
    }
}

/// Helper function to determine if a tracker is considered safe.
/// A tracker is safe if it is ignored or if its connection status is "OwnerConnected".
func trackerIsSafe(tracker: BaseDevice) -> Bool {
    return tracker.ignore ||
           tracker.getType.constants.connectionStatus(advertisementData: tracker.bluetoothTempData().advertisementData_publisher) == .OwnerConnected
}

/// Returns a localized error header based on the Bluetooth state.
func getBluetoothProblemHeader() -> String {
    return (BluetoothManager.sharedInstance.centralManager?.state == .unauthorized
            ? "no_bluetooth_access"
            : "bluetooth_off").localized()
}

/// Returns a localized error description based on the Bluetooth state.
func getBluetoothProblemSubHeader() -> String {
    return (BluetoothManager.sharedInstance.centralManager?.state == .unauthorized
            ? "no_bluetooth_access_description"
            : "bluetooth_off_description").localized()
}

// MARK: - Preview Provider
struct Previews_ManualScanningView_Previews: PreviewProvider {
    
    static var previews: some View {
        ManualScanningView()
            .onAppear{
                // Configure settings for preview purposes.
                Settings.sharedInstance.isBackground = false
                BluetoothManager.sharedInstance.turnedOn = true
            }
    }
}
