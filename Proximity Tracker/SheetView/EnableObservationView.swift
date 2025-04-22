//
//  EnableObservationView.swift
//  Promixity Tracker
//
//  Created by user238598 on 4/2/24.
//

struct EnableObservationView: View {
    // View providing UI to enable observation for a tracker
    
    @Binding var observationEnabled: Bool    // Binding to whether observation mode is enabled for the tracker
    @ObservedObject var tracker: BaseDevice    // The tracker device to potentially observe
    
    @State var showObserveUnavailableAlert = false    // Controls showing an alert if observation cannot be enabled
    @ObservedObject var settings = Settings.sharedInstance    // Shared settings (to check background scanning availability)
    @Environment(\.presentationMode) private var presentationMode    // Allows dismissing this view programmatically
    
    var body: some View {
        
        BigButtonView(buttonHeight: Constants.BigButtonHeight,
                      mainView: BigSymbolViewWithText(title: "observe_tracker", symbol: "clock.fill", subtitle: "observe_tracker_description", topPadding: 0),    // Large symbol and text describing "Observe Tracker"
                      buttonView: ColoredButton(action: {
            // Action to perform when "Start Observation" button is tapped
            if tracker.ignore || !settings.backgroundScanning {    // If tracker is ignored or background scanning is off
                showObserveUnavailableAlert = true    // Show an alert that this feature is unavailable
            } else {    // Otherwise, proceed to enable observation
                observationEnabled = true    // Enable observation mode for this tracker
                presentationMode.wrappedValue.dismiss()    // Dismiss this view after enabling
            }
        }, label: "start_observation")
                      .alert(isPresented: $showObserveUnavailableAlert) {    // Present an alert when feature is unavailable
                          Alert(title: Text("feature_unavailable"), message: Text("observing_unavailable_description"))
                      },
                      hideNavigationBar: false
        )
    }
}

struct Previews_EnableObservationSheet_Previews: PreviewProvider {
    static var previews: some View {
        EnableObservationView(observationEnabled: .constant(false), tracker: BaseDevice(context: PersistenceController.sharedInstance.container.viewContext))    // Preview with a sample tracker and observation disabled by default
    }
}
