//
//  DetailGeneralView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//


struct DetailGeneralView: View {
    // Section with general controls: locate, observe, ignore tracker
    
    @ObservedObject var tracker: BaseDevice    // The tracker device model
    @ObservedObject var settings = Settings.sharedInstance    // App settings (for background scanning info)
    @ObservedObject var soundManager: SoundManager    // Manages playing sounds (not directly used here)
    @ObservedObject var clock = Clock.sharedInstance    // Shared clock object
    
    let persistenceController = PersistenceController.sharedInstance    // Persistence controller for Core Data
    
    @State var showPrecisionFinding = false    // Controls showing the Precision Finding (Locate) view
    @State var observingWasTurnedOn = false    // Remembers if observation was enabled in this session
    
    var body: some View {
        
        let notCurrentlyReachable = deviceNotCurrentlyReachable(device: tracker, currentDate: clock.currentDate)
        
        CustomSection(header: "general", footer: tracker.getType.constants.supportsIgnore ? "ignore_trackers_footer" : "") {
            
            VStack(spacing: 0) {
                
                Button {
                    showPrecisionFinding = true    // Trigger showing the Precision Finding interface
                } label: {
                    NavigationLinkLabel(imageName: "smallcircle.fill.circle.fill", text: "locate_tracker", backgroundColor: .accentColor, status: notCurrentlyReachable ? "" : "nearby")
                }    // Button to open Precision Finding (shows as NavigationLink label)
                
                if tracker.getType.constants.supportsIgnore || tracker.getType.constants.supportsBackgroundScanning {
                    CustomDivider()    // Divider above observation/ignore toggles if needed
                }
                
                if tracker.getType.constants.supportsBackgroundScanning {
                    // Background scanning supported: provide Observation toggle or link
                    let binding = Binding { tracker.observingStartDate != nil } set: { newValue in
                        if newValue {
                            observingWasTurnedOn = true
                            // (Start observing tracker in background - code commented out)
                        } else {
                            // (Stop observing tracker in background - code commented out)
                        }
                    }
                    
                    let color = Color(#colorLiteral(red: 0.3667442501, green: 0.422971189, blue: 0.9019283652, alpha: 1))
                    
                    if binding.wrappedValue || observingWasTurnedOn {
                        Toggle(isOn: binding) {
                            SettingsLabel(imageName: "clock.fill", text: "observe_tracker", backgroundColor: color)
                        }
                        .onAppear { observingWasTurnedOn = true }
                    } else {
                        NavigationLink {
                            EnableObservationView(observationEnabled: binding, tracker: tracker)
                        } label: {
                            NavigationLinkLabel(imageName: "clock.fill", text: "observe_tracker", backgroundColor: color, status: "off")
                        }
                    }
                    
                    if tracker.getType.constants.supportsIgnore {
                        CustomDivider()
                    }
                }
                
                if tracker.getType.constants.supportsIgnore {
                    // Provide option to ignore/unignore this tracker
                    let binding = Binding(get: { tracker.ignore }, set: { newValue in
                        modifyDeviceOnBackgroundThread(objectID: tracker.objectID) { context, tracker in
                            tracker.ignore = newValue    // Update ignore status in background context
                            // (If ignoring, tracking might stop - commented out)
                        }
                    })
                    
                    Toggle(isOn: binding) {
                        SettingsLabel(imageName: "nosign", text: "ignore_this_tracker", backgroundColor: .red)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showPrecisionFinding) {
            PrecisionFindingView(tracker: tracker, bluetoothData: tracker.bluetoothTempData(), soundManager: soundManager, isShown: $showPrecisionFinding)
        }
    }
}

struct Previews_TrackerGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        
        let vc = PersistenceController.sharedInstance.container.viewContext
        
        let device = BaseDevice(context: vc)
        device.setType(type: .Tile)
        device.firstSeen = Date()
        device.lastSeen = Date()
        
        try? vc.save()
        
        return NavigationView {
            TrackerDetailView(tracker: device, bluetoothData: BluetoothTempData(identifier: UUID().uuidString))
                .environment(\.managedObjectContext, vc)
        }
    }
}
