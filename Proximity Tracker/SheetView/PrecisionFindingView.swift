//  PrecisionFindingView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI
import Combine

struct PrecisionFindingView: View {
    // View for the precision finding (close-range tracking) UI
    
    @ObservedObject var tracker: BaseDevice    // Tracker device being located (observed for updates)
    @ObservedObject var bluetoothData: BluetoothTempData    // Live Bluetooth data (RSSI, etc.) for the tracker
    @ObservedObject var soundManager: SoundManager    // Sound manager to handle playing sounds and sound state
    @ObservedObject var clock = Clock.sharedInstance    // Shared clock instance for timing (current date)
    @State private var showSoundErrorInfo = false    // Controls display of sound error information alert
    @Binding var isShown: Bool    // Binding to whether this view is shown (to allow dismissing from outside)
    
    @Environment(\.colorScheme) var colorScheme    // Detect current color scheme (light/dark) for UI adjustments
    
    @State var isStarted = false    // Tracks whether the precision finding scan has started
    
    @Environment(\.scenePhase) var scenePhase    // Monitor app's scene phase (active/inactive) to handle pauses
    @Environment(\.safeAreaInsets) private var safeAreaInsets    // Safe area insets for padding content away from notches
    
    var body: some View {
        
        let maxRSSI = Double(tracker.getType.constants.bestRSSI)    // Maximum RSSI value for this tracker type (used for 100% signal strength)
        
        let notReachable = deviceNotCurrentlyReachable(device: tracker, currentDate: clock.currentDate, timeout: 45)    // Determine if the device is currently not reachable (no signal within 45 seconds)
        
        let rssi = !isStarted || notReachable ? Constants.worstRSSI : Double(bluetoothData.rssi_publisher)    // Use worst RSSI if not started or device not reachable; otherwise use current RSSI value
        
        let pct = rssiToPercentage(rssi: rssi, bestRSSI: maxRSSI)    // Convert the RSSI into a percentage of maximum signal strength
        
        let delay: CGFloat = 2    // Delay (in seconds) for animation transitions
        
        GeometryReader { geo in    // Use geometry proxy to get the full available size for layout
            
            let fullHeight = geo.size.height    // Total height available for the precision finding overlay
            
            ZStack {    // Overlay the two colored signal strength layers (top colored overlay and bottom background)
                
                VStack(spacing: 0) {    // Top overlay layer for signal strength (colored portion)
                    
                    ZStack {    // Top overlay content: colored background and overlay elements (white text and indicator)
                        Color.accentColor.opacity(colorScheme.isLight ? 0.6 : 1)    // Semi-transparent accent color background (lighter in light mode, solid in dark mode)
                        
                        PrecisionOverlayElements(tracker: tracker, soundManager: soundManager, pct: pct, rssi: rssi, animationDelay: delay, textColor: .white, notReachable: notReachable)    // Overlay elements (text and indicator) on top portion, with white text
                            .padding(safeAreaInsets)    // Apply safe area padding so content isn't under notch or home indicator
                            .frame(height: fullHeight)    // Expand overlay elements to full height inside ZStack
                    }
                    .frame(height: fullHeight * pct, alignment: .bottom)    // Set this view's height to pct portion of full height (anchor to bottom)
                    .clipped()    // Clip content to its frame bounds
                }
                .frame(height: fullHeight, alignment: .bottom)    // Occupy full height for top overlay, anchored to bottom
                
                VStack(spacing: 0) {    // Bottom overlay layer (remaining background portion)
                    
                    ZStack {    // Bottom overlay content: base background and overlay elements (colored text)
                        (colorScheme.isLight ? Color.white : Color.formDeepGray)    // Background color for bottom portion (white for light mode, dark gray for dark mode)
                        
                        PrecisionOverlayElements(tracker: tracker, soundManager: soundManager, pct: pct, rssi: rssi, animationDelay: delay, textColor: Color("MainColor"), notReachable: notReachable)    // Overlay elements for bottom portion, with main color text
                            .padding(safeAreaInsets)    // Apply safe area padding so content isn't under notch or home indicator
                            .frame(height: fullHeight)    // Expand overlay elements to full height inside ZStack
                        
                    }
                    .frame(height: fullHeight * (1-pct), alignment: .top)    // Set this view's height to the remaining (1 - pct) portion of full height (anchor to top)
                    .clipped()    // Clip content to its frame bounds
                }
                .frame(height: fullHeight, alignment: .top)
            }
        }
        .ignoresSafeArea()    // Extend the view to cover the safe area (edges)
        .animation(.easeInOut(duration: delay), value: pct)    // Animate changes to the percentage smoothly using the delay
        
        .onAppear {    // When view appears:
            isStarted = true    // Mark scanning as started
            startScan()    // Begin scanning for the device's signal
        }
        .onDisappear {    // When view disappears:
            BluetoothManager.sharedInstance.disableFastScan()    // Stop the fast scan mode
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in    // Respond to app state changes
            if newPhase == .active {    // If app moved to active state (foreground)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: ) {    // Wait 1 second and then:
                    startScan()    // Restart scanning to refresh data
                }
            }
        }
    }
    
    func startScan() {    // Initiate fast Bluetooth scan for the tracker
        var uuids = [UUID]()    // Prepare list of UUIDs to filter the scan for specific devices
        if let trackerUUIDstring = tracker.currentBluetoothId, let trackerUUID = UUID(uuidString: trackerUUIDstring) {
            uuids.append(trackerUUID)    // Add tracker's Bluetooth UUID to the filter list
        }
        if tracker.getType.constants.supportsBackgroundScanning {
            BluetoothManager.sharedInstance.enableFastScan(for: RSSIScan(service: tracker.getType.constants.offeredService), allowedUUIDs: uuids)    // Start fast scanning using the tracker's service UUID (for background scanning capable devices)
        } else {
            BluetoothManager.sharedInstance.enableFastScan(for: RSSIScan(bluetoothDevice: tracker.currentBluetoothId), allowedUUIDs: uuids)    // Start fast scanning targeting the specific device ID
        }
    }
}

struct PrecisionOverlayElements: View {
    // Overlay UI components for precision finding (text, indicator, etc.)
    @Environment(\.colorScheme) var colorScheme    // Access color scheme (unused directly here but available)
    @ObservedObject var tracker: BaseDevice    // The tracker device (for name and statuses)
    @ObservedObject var soundManager: SoundManager    // Sound manager to trigger vibrations based on signal changes
    @State var lastVibration = Date.distantPast    // Time of last vibration (initialized to distant past)
    let pct: CGFloat    // Current proximity percentage (0 to 1)
    let rssi: CGFloat    // Current RSSI value (signal strength)
    let animationDelay: CGFloat    // Delay used for animations
    let textColor: Color    // Color to use for text (depends on overlay segment)
    let notReachable: Bool    // Whether the tracker is currently not reachable
    
    var body: some View {
        VStack {    // Vertical stack of overlay content
            Text(tracker.getName)    // Tracker's name displayed
                .bold()    // Bold font for emphasis
                .font(.largeTitle)    // Large title font size
                .lineLimit(1)    // Only allow one line for the name (truncate if too long)
                .minimumScaleFactor(0.8)    // If text is long, allow it to shrink to 80% to fit
                .foregroundColor(textColor)    // Use the specified text color (white or main color)
                .padding()    // Add default padding around the name text
                .padding(.top)    // Add extra padding at the top
            
            Spacer()    // Spacer pushes content to top (pushes the name up)
            
            Indicator(pct: pct, color: textColor)    // Circular visual indicator showing signal strength percentage
                .onChange(of: pct) { oldPct, newPct in    // When signal percentage changes, handle haptic feedback
                    if newPct == 0 {    // If signal lost completely
                        errorVibration()    // Emit an error vibration
                    } else if abs(oldPct - newPct) > 0.05, self.lastVibration.isOlderThan(seconds: 5) {    // If significant change and enough time since last vibration
                        lastVibration = Date()    // Update the last vibration timestamp to now
                        if oldPct > newPct {    // If the signal got weaker (user is moving away)
                            errorVibration()    // Single vibration indicating getting farther away
                        } else {    // Otherwise, signal got stronger (user is getting closer)
                            doubleVibration()    // Double vibration indicating getting closer
                        }
                    }
                }
            
            Group {    // Group for conditional connection hint or precision-finding hint text
                if notReachable {    // If the tracker is not currently reachable
                    HStack {    // Horizontal layout for "trying to connect" message and spinner
                        Text("trying_connection")    // "Trying to connect" localized text
                            .bold()    // Bold text for emphasis
                        ProgressView()    // Spinning activity indicator
                            .padding(5)    // Small padding around the spinner
                    }
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.1)))    // Fade transition for appearance/disappearance of this text
                } else {    // If the tracker is reachable
                    Text("precision_finding_hint")    // Instruction hint text for precision finding
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.1)))    // Fade transition for appearance/disappearance of this text
                }
            }
            .opacity(textColor == .white ? 1 : 0.7)    // Slightly dim the text if using main color (to improve contrast)
            .foregroundColor(textColor)    // Use the same text color for the hint
            .padding(.horizontal)    // Add horizontal padding around the text group
            .centered()    // Center the content horizontally (custom modifier)
            .padding()    // Add overall padding around the group
            
            Spacer()    // Spacer pushes remaining content to bottom
            
            SoundAndCloseView(soundManager: soundManager, tracker: tracker)    // View containing the sound play button and close button
        }
    }
}

struct SoundAndCloseView: View {
    @ObservedObject var soundManager: SoundManager    // Sound manager for controlling sound playback
    @ObservedObject var tracker: BaseDevice    // Tracker device, used to check capabilities (e.g., can it play sound)
    @State private var showSoundErrorInfo = false    // Controls display of an alert when a sound playback error occurs
    @Environment(\.presentationMode) var presentationMode    // Presentation mode to allow dismissing this view
    
    var body: some View {
        CustomSection {    // Custom styled section containing the sound and close buttons
            VStack(spacing: 0) {    // Stack buttons vertically without spacing
                if tracker.getType.constants.canPlaySound {    // If the tracker supports playing a sound
                    Button {    // Button to play a sound on the tracker
                        mediumVibration()    // Provide a medium haptic feedback when tapping play sound
                        soundManager.playSound(constants: tracker.getType.constants, bluetoothUUID: tracker.currentBluetoothId)    // Trigger the sound manager to play the tracker's sound
                    } label: {
                        HStack {    // Label content for the play sound button
                            SettingsLabel(imageName: "speaker.wave.2.fill", text: "play_sound", backgroundColor: .orange)    // Label with speaker icon and "Play Sound" text (orange background)
                                .fixedSize(horizontal: true, vertical: false)    // Prevent the label from expanding horizontally
                            
                            ZStack {    // Overlay stack for dynamic status text on the button
                                HStack {    // "Connecting..." status text with spinner
                                    Spacer()
                                    Text("connecting_in_progress")    // "Connecting..." message indicating connection to device
                                        .lineLimit(1)    // Ensure status text is on one line
                                        .foregroundColor(.gray)    // Gray color for status text
                                        .padding(.trailing, 7)    // Small right padding to separate from spinner
                                    ProgressView()    // Spinner indicating ongoing action
                                }
                                .opacity(soundManager.soundRequest ? 1 : 0)    // Show "Connecting..." view only when a sound request is in progress
                                
                                HStack {    // "Playing..." status text
                                    Spacer()
                                    Text("playing_in_progress")    // "Playing..." message indicating sound is playing
                                        .lineLimit(1)    // Ensure status text is on one line
                                        .foregroundColor(.gray)    // Gray color for status text
                                }
                                .opacity(soundManager.playingSound ? 1 : 0)    // Show "Playing..." view only when sound is currently playing
                                
                                if let error = soundManager.error {    // If a sound playback error occurred
                                    HStack {    // Display error title text
                                        Spacer()
                                        Text(error.title)    // Show the error title from sound manager
                                            .lineLimit(1)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .alert(isPresented: $showSoundErrorInfo) {    // Present an alert when showSoundErrorInfo is true
                                Alert(title: Text(soundManager.error?.title ?? ""), message: Text(soundManager.error?.description ?? ""))    // Alert showing error title and description
                            }
                            .onChange(of: soundManager.error) { oldVal, val in
                                if val != nil {
                                    showSoundErrorInfo = true    // If an error occurs, set flag to show alert
                                }
                            }
                        }
                    }
                    CustomDivider()    // Divider between the play sound button and close button
                }
                Button {    // Button to close the precision finding view
                    presentationMode.wrappedValue.dismiss()    // Dismiss this view
                } label: {
                    SettingsLabel(imageName: "xmark", text: "close_stop_searching", backgroundColor: .red)    // Label with X icon and "Close/Stop Searching" text (red background)
                }
            }
        }
        .frame(maxWidth: Constants.maxWidth)    // Limit the section's max width for layout
        .padding(.bottom)    // Add padding at the bottom of the section
    }
}

struct Indicator: View {    // Simplified view for the signal indicator arc
    var pct: CGFloat
    let color: Color
    
    var body: some View {
        Color.clear    // Invisible base (placeholder for overlay)
            .frame(height: 100)    // Fixed height for the indicator area
            .modifier(PercentageIndicator(pct: self.pct, color: color))    // Apply the percentage indicator modifier to draw the arc and label
            .padding(.horizontal)    // Horizontal padding around the indicator
    }
}

struct PercentageIndicator: AnimatableModifier {    // Modifier that draws an arc and percentage label, animating with changes
    var pct: CGFloat
    let color: Color
    
    var animatableData: CGFloat {
        get { pct }    // Use pct as the animatable data for implicit animations
        set { pct = newValue }    // Update pct when animation changes it
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(LabelView(pct: pct, color: color))    // Overlay the percentage label (and arc) on the content
    }
    
    struct ArcShape: Shape {    // Shape for drawing a portion of a circle (arc) representing the signal strength
        let pct: CGFloat    // Current proximity percentage (0 to 1)
        
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.addArc(center: CGPoint(x: rect.width / 2.0, y: rect.height / 2.0),
                     radius: rect.height / 2.0 + 5.0,
                     startAngle: .degrees(0),
                     endAngle: .degrees(360.0 * Double(pct)), clockwise: false)    // Draw an arc from 0° to (pct * 360)°
            return p.strokedPath(.init(lineWidth: 10, lineCap: .round))    // Stroke the arc path with a 10pt line and rounded end caps
        }
    }
    
    struct LabelView: View {    // Overlay label showing the percentage value
        let pct: CGFloat    // Current proximity percentage (0 to 1)
        let color: Color
        
        var body: some View {
            Text("\(Int(pct * 100))%")    // Percentage number text
                .font(.system(size: 100))    // Very large font size for percentage text
                .fontWeight(.ultraLight)    // Ultra light font weight for a thin look
                .foregroundColor(color)    // Use the provided color for the text
        }
    }
}

struct Previews_PrecisionFindingView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.sharedInstance.container.viewContext    // Set up a Core Data context for preview data
        
        let device = BaseDevice(context: vc)    // Create a sample device
        device.setType(type: .AirTag)    // Use AirTag type for example
        
        let tempdata = BluetoothTempData(identifier: "XY")    // Create sample Bluetooth data object
        tempdata.rssi_background = -50    // Simulate an RSSI value for the background context (e.g., -50 dBm)
        
        try? vc.save()    // Save the context with the sample data
        
        return NavigationView {
            PrecisionFindingView(tracker: device, bluetoothData: tempdata, soundManager: SoundManager(), isShown: .constant(true))    // PrecisionFindingView with sample device, dummy sound manager, shown binding true
                .environment(\.managedObjectContext, vc)    // Inject the managed object context into the environment
        }
    }
}
