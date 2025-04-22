//
//  SettingView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

struct SettingsView: View {    // Settings screen view with various toggle and info sections
    
    @ObservedObject var settings = Settings.sharedInstance // Shared app settings model (singleton)
    
    @ObservedObject var notificationManager = NotificationManager.sharedInstance // Singleton managing notification permissions and related actions
    @ObservedObject var locationManager = LocationManager.sharedInstance // Singleton managing location services and permissions
    
    @State var showPermissionSheet = false // Controls display of a permission request sheet
    
#if DEBUG
    @State var showDebugOptions = true // Flag to toggle debug settings (default ON in debug builds)
#else
    @State var showDebugOptions = false // Flag to toggle debug settings (default OFF in release builds)
#endif
    
    @State var showStudyConsentDeclaration = false // Used to present the study consent screen full-screen
    
    /// Data deletion failed or succeeded
    @State var dataDeletionState: DataDeletionState? = nil // Tracks outcome of data deletion (.failed or .succeeded) to trigger alerts
    /// If true, a request is currently running that deletes the user study data
    @State var isDeletingStudyData = false // True while a study data deletion request is in progress (shows spinner)
    
    
    let url = "https://tpe.seemoo.tu-darmstadt.de/privacy-policy.html" // Privacy policy URL (used for a link in info section, if enabled)
    
    var body: some View { // Defines the content and layout of the Settings screen
        
        NavigationView { // Begin navigation context for the settings screen
            
            NavigationSubView(spacing: Constants.SettingsSectionSpacing) { // Content container with standard padding for sections
                
                // backgroundScanningSection
                
                if Constants.StudyIsActive { // If a study is active, include study-related settings section (currently disabled)
                    //studySection
                }
                
                infoSection // Include the informational section with app details/contact
                
                
                /*if(showDebugOptions) {
                    CustomSection(header: "Debug") {
                        NavigationLink {
                            DebugSettingsView()
                                .modifier(GoToRootModifier(view: .Settings))
                        } label: {
                            NavigationLinkLabel(imageName: "curlybraces", text: 
"Debug Settings")
                        }
                    }
                }*/
                
            }
            .navigationBarTitle("settings") // Set the navigation bar title to "Settings"
            
        } .navigationViewStyle(StackNavigationViewStyle()) // Use stack style navigation view (single-column) for all devices
    }
    
    /*
    var backgroundScanningSection: some View {
        
        CustomSection(header: "background_scanning", footer: 
settings.securityLevel.description.localized()) {
            Toggle(isOn: $settings.backgroundScanning) {
                SettingsLabel(imageName: "text.magnifyingglass", text: 
"background_scanning", backgroundColor: .green)
                    .simultaneousGesture(LongPressGesture(minimumDuration: 
0.5).onEnded({_ in showDebugOptions = true}))
            }
            .onChange(of: settings.backgroundScanning, perform: { newValue in
                 
                // enabled background scanning
                if(newValue) {
                     
                    UNUserNotificationCenter.current().getNotificationSettings { 
 notificationSettings in
                         
                        if notificationSettings.authorizationStatus != 
 .authorized || !locationManager.hasAlwaysPermission() {
                             
                            // show tutorial again to set permissions
                            DispatchQueue.main.async {
                                settings.backgroundScanning = false
                                settings.tutorialCompleted = false
                            }
                             
                        }
                        else {
                            locationManager.enableBackgroundLocationUpdate()
                        }
                    }
                }
                 
                // disabled background scanning
                else {
                    locationManager.disableBackgroundLocationUpdate()
                }
            })
            
            
            
            NavigationLink {
                DisableDevicesView()
                    .modifier(GoToRootModifier(view: .Settings))
            } label: {
                NavigationLinkLabel(imageName: "nosign", text: 
"manage_ignored_devices", backgroundColor: .orange)
            }     .disabled(!settings.backgroundScanning)
            
            
            CustomPickerLabel(selection: 
 settings.securityLevel.name.localized(), backgroundColor: .yellow, description: 
"security_level", imageName: settings.securityLevel.image)
                .disabled(!settings.backgroundScanning)
            
            
            Picker("", selection: $settings.securityLevel) {
                ForEach(SecurityLevel.allCases, id: \.self) { level in
                     
                    Text(level.name.localized())
                     
                        .id(level.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(height: Constants.SettingsLabelHeight)
            .disabled(!settings.backgroundScanning)
        }
    }
 
    var studySection: some View {
        CustomSection(header: "study_settings", footer: 
"survey_description_short") {
             
            VStack(spacing: 0) {
                 
                ZStack {
                    Toggle(isOn: $settings.participateInStudy.animation()) {
                        SettingsLabel(imageName: "waveform.path.ecg", text: 
"participate_study")
                    }
                    .opacity(settings.participateInStudy ? 1 : 0)
                     
                     
                    Button {
                        showStudyConsentDeclaration = true
                    } label: {
                        NavigationLinkLabel(imageName: "waveform.path.ecg", 
 text: "participate_study")
                    }
                    .opacity(settings.participateInStudy ? 0 : 1)
                     
                }
                 
                 
                if settings.participateInStudy {
                     
                    CustomDivider()
                     
                    Button {
                        requestDataDeletion()
                    } label: {
                        if !isDeletingStudyData {
                            NavigationLinkLabel(imageName: "trash.fill", text: 
"delete_study_data", backgroundColor: .red, isNavLink: false)
                        }else {
                            HStack{
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .buttonStyle(.plain)
                }
                 
                // Survey
                if Constants.SurveyIsActive {
                     
                    CustomDivider()
                     
                    Button {
                        guard let url = URL(string: "survey_link".localized()) 
 else {return}
                        UIApplication.shared.open(url)
                    } label: {
                        VStack {
                            NavigationLinkLabel(imageName: "doc.fill", text: 
"participate_in_survey", backgroundColor: .green, isNavLink: false)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showStudyConsentDeclaration) {
                StudyOptInView { participate in
                    settings.participateInStudy = participate
                    showStudyConsentDeclaration = false
                }
            }
            .alert(item: $dataDeletionState, content: { dataDeletionState in
                switch dataDeletionState {
                case .failed:
                    return _(title: Text("deletion_failed"), message: 
 Text("deletion_failed_message"), dismissButton: Alert.Button.cancel())
                case .succeeded:
                    return Alert(title: Text("deletion_succeeded"), message: 
 Text("deletion_succeeded_message"), dismissButton: Alert.Button.cancel())
                }
            })
 
        }
    }
    */
    var infoSection: some View { // Section providing app information and contact options
        CustomSection(header: "info") { // Section container with "Info" header
             
            NavigationLink { // Tapping opens the InformationView (app info & contact screen)
                InformationView()
                    // .modifier(GoToRootModifier(view: .Settings))
            } label: {
                NavigationLinkLabel(imageName: "info", text: 
"information_and_contact", backgroundColor: Color.green) // Label with info icon and "Information and Contact" text
                 
            }
            /*
            if let url = URL(string: url) {
                Link(destination: url, label: {
                    NavigationLinkLabel(imageName: "hand.raised.fill", text: 
"privacy_policy", backgroundColor: .red, isNavLink: false)
                })
            }
            */
        }
    }
    
    func requestDataDeletion() { // Attempt to delete the user's study data from the server
        // Get the UUID from the data study
        /*
        guard let studyUUID = UserDefaults.standard.string(forKey: 
"dataDonatorToken") else {
            // No data has been uploaded yet, so we can just end here
            dataDeletionState = .succeeded
            return
        }
         */
        
        var deletionSucceeded = false // Flag to indicate if deletion succeeded (helps manage spinner timing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            guard !deletionSucceeded else { return } // Only proceed if deletion still ongoing after delay
            // If the deletion takes more than 1s, we show an indicator
            self.isDeletingStudyData = true // Activate the 'deleting data' state to show a loading indicator
        })
        
        Task { // Launch asynchronous task to perform deletion
            // Call the URL to delete study data
            do {
                // try await API.deleteStudyData(token:studyUUID) // (API call to delete data is commented out for now)
                await MainActor.run { // Switch to main actor to perform UI updates after deletion
                    deletionSucceeded = true // Mark deletion as succeeded to prevent the spinner from showing
                    self.isDeletingStudyData = false // Deactivate the 'deleting data' state (stop spinner)
                    
                    withAnimation {
                        settings.participateInStudy = false // Animate changes: user is opted out of study upon successful deletion
                        dataDeletionState = .succeeded // Set state to show a success alert for data deletion
                    }
                    UserDefaults.standard.removeObject(forKey: 
"dataDonatorToken") // Remove the stored study token now that data is deleted
                }
            }
        }
        
    }
    
    func sendStudyDeletionMail(studyUUID: String) { // Open a mail composer to request data deletion via email
        // Construct a mailto url
        let mailContent = "I hereby request the deletion of the data gathered from the Promixty Tracker application. Deleting data over the app integration failed. My app identifier is \(studyUUID).\n\n Please get back to me when the deletion has been performed.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // Prepare the email body content with percent-encoding
         
        let subjectContent = "Proximity Tracker Study Data Deletion Request".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // Prepare the email subject content with percent-encoding
         
        guard let mailContent, let subjectContent else {
            dataDeletionState = .failed // If content encoding failed, mark deletion as failed
            return
        }
         
        let mailtoURLstring = "mailto:aheinrich@seemoo.tu-
darmstadt.de?subject=\(subjectContent)&body=\(mailContent)" // Form the mailto URL with recipient, subject, and body
         
        guard let url = URL(string: mailtoURLstring) else {
            dataDeletionState = .failed // Validate the mailto URL string
            return
        }
         
        UIApplication.shared.open(url) { success in // Launch the mail app with the composed email
            if success {
                withAnimation {
                    settings.participateInStudy = false // If mail app opened, assume user will send mail; opt-out of study now
                }
            } else {
                dataDeletionState = .failed // If mail app couldn't open, mark deletion as failed (to trigger alert)
            }
        }
    }
    
    enum DataDeletionState: Int, Identifiable { // Enum representing possible results of data deletion request
        var id: Int { return self.rawValue } // Provide an 'id' for Identifiable conformance using raw value
        
        case failed   // Indicates the data deletion request failed
        case succeeded   // Indicates the data deletion request succeeded
    }
}
 

struct Previews_SettingsView_Previews: PreviewProvider { // Preview provider for SwiftUI (development previews)
    static var previews: some View { // Define the preview content
        SettingsView() // Display SettingsView in the preview canvas
    }
}
