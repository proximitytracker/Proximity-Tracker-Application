//
//  DisableDevicesView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

struct DisableDevicesView: View {    // View for managing ignored (disabled) devices and types
    
    @FetchRequest( // Fetch ignored devices from Core Data (ignore == TRUE and has a type)
        sortDescriptors: [NSSortDescriptor(keyPath: \BaseDevice.firstSeen, ascending: true)], // Sort devices by first seen date ascending
        predicate: NSPredicate(format: "ignore == TRUE && deviceType != nil"), // Only include devices that are marked as ignored and have a deviceType
        animation: .spring()) // Use a spring animation for any changes in the fetched results
    private var devices: FetchedResults<BaseDevice> // FetchedResults of BaseDevice matching the predicate
    
    
    var body: some View { // Defines the UI layout for the ignore devices screen
        
            NavigationSubView { // Container for navigation content, likely providing styling
                
                CustomSection(header: "device_types", footer: "ignore_type_footer") { // Section for toggling ignore status by device category
                    
                    
                    let types = DeviceType.allCases.filter({$0 != .Unknown && $0.constants.supportsBackgroundScanning}) // Determine all device types that can be ignored (excluding unknown types)
                    
                    ForEach(types) { type in // List a toggle for each device type
                        
                        DisableDeviceTypeView(deviceType: type) // Row view containing the toggle for this device type
                        
                        if(type != types.last) {
                            CustomDivider() // Insert a divider between type toggles for visual separation
                        }
                    }
                }
                
                if(devices.count >= 1) { // If there are any ignored devices, show them in a list
                    CustomSection(header: "devices") { // Section listing individual devices that have been ignored
                        
                        
                        ForEach(devices) { device in // Iterate over each ignored device
                            
                            DeviceEntryButton(device: device) // Show a button or row for this individual device (likely to allow unignoring)
                            
                            if(device != devices.last) {
                                CustomDivider() // Insert a divider between device entries
                            }
                        }
                    }.padding(.top) // Add spacing above this section to separate from prior content
                }
                  
                Spacer() // Push content to top (fills remaining space)
                 
            }
            .navigationTitle("ignored_devices") // Set the navigation bar title for this screen
    }
}
 

struct DisableDeviceTypeView: View {    // View for a toggle controlling a specific device type ignore setting
     
    let deviceType: DeviceType // The device type this view controls
     
    var body: some View {
         
        let binding = Binding { // Create a binding to the device type's ignore flag (get and set methods)
            deviceType.getIgnore() // Get the current ignore status for this device type
        } set: { newValue in
            deviceType.setIgnore(toValue: newValue) // Update the ignore status for this device type
        }
         
        Toggle(isOn: binding) { // Toggle switch bound to the device type's ignore setting
            HStack { // Layout for toggle label contents
                deviceType.constants.iconView // Icon representing this device type
                Text("ignore_every".localized() + " " + deviceType.constants.name) // Text label "Ignore every [DeviceTypeName]"
                    .foregroundColor(Color("MainColor")) // Use the app's main color for the text
                 
                Spacer() // Push text to leading side, keeping toggle on trailing side
            }.frame(height: Constants.SettingsLabelHeight) // Ensure consistent height for toggle row
        }
    }
}
 

struct Previews_DisableDevicesView_Previews: PreviewProvider { // Preview provider for this view
    static var previews: some View {
        NavigationView {
            DisableDevicesView() // Display DisableDevicesView inside a NavigationView for preview
        }
    }
}
