//
//  DetailDebugView.swift
//  Promixity Tracker
//
//  Created by user238598 on 4/2/24.
//


struct DetailDebugView: View {
    // Debug-only section with various diagnostic controls and info
    @ObservedObject var tracker: BaseDevice
    @ObservedObject var settings = Settings.sharedInstance
    @ObservedObject var bluetoothData: BluetoothTempData
    
    var body: some View {
        if settings.debugMode {    // Only show this debug view when debug mode is enabled
             
            VStack {    // Container for delete button
                Button(action: {
                    PersistenceController.sharedInstance.modifyDatabase { context in
                        context.delete(tracker)
                    }
                }, label: {
                    Text("Core data delete entry")    // Button label to delete the tracker data
                })
            }
             
            VStack {    // Container for debug text info
                Text("Last MAC refresh: \(tracker.lastMacRenewal?.description ?? \"---\")")    // Last time MAC address was refreshed
                Text("Additional data: \(tracker.additionalData?.description ?? \"---\")")    // Additional data stored in tracker (if any)
                if let service = tracker.getType.constants.offeredService {
                    Text("service data: \(getServiceData(advertisementData: bluetoothData.advertisementData_publisher, key: service) ?? \"no value\")")    // Service-specific data from advertisement (if available)
                }
            }
           
            if let services = bluetoothData.peripheral_background?.services {
                ForEach(services, id: \.self) { service in
                    Text(service.uuid.description)    // Display UUID of each discovered service
                }
            }
             
            Button {    // Button to simulate adding a detection event
                log("Adding fake detection...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    PersistenceController.sharedInstance.modifyDatabase { context in
                        tracker.lastSeen = Date()    // Update last seen time to now (simulate detection)
                        // (Add detection event in tracking system - commented out)
                    }
                }
            } label: {
                Text("Add fake detection event")
            }
             
            Text("Detections: \(tracker.detectionEvents?.count ?? 0)")    // Show count of detection events
             
            if let peripheral = bluetoothData.peripheral_background {
                Button {    // Button to attempt Bluetooth connection to the peripheral
                    BluetoothManager.sharedInstance.centralManager?.connect(peripheral)
                    peripheral.discoverServices(nil)
                } label: {
                    Text("Connect")
                }
            }
             
            Text("Connected: \(bluetoothData.connected_background.description)")    // Show whether device is connected
            Text(bluetoothData.advertisementData_publisher.description)    // Show raw advertisement data
             
            Group {    // Show various identifier values
                Text("UniqueID: " + (tracker.uniqueId?.description ?? "no id"))
                Text("CurrentBluetoothID: " + (tracker.currentBluetoothId?.description ?? "no id"))
                Text("PeripheralID: " + (bluetoothData.peripheral_background?.identifier.description ?? "no id"))
                Text("BluetoothDataID: " + (bluetoothData.identifier_background))
            }
             
            VStack {    // List all detection events
                if let detections = tracker.detectionEvents?.array as? [DetectionEvent] {
                    ForEach(detections, id: \.self) { detection in
                        Text("\(detection.time?.description ?? "-") \(detection.connectionStatus?.description ?? "-")")
                        // Show each detection's time and connection status
                        Button {    // Button to delete this detection event
                            PersistenceController.sharedInstance.modifyDatabase { context in
                                context.delete(detection)    // Remove detection event
                            }
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
        }
    }
}
