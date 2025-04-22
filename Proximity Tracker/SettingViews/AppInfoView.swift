//
//  AppInfoView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

// InformationView displays app info and provides contact and credits sections
struct InformationView: View {
    
    // Access the environment's openURL helper to open external links
    @Environment(\.openURL) var openURL
    
    // The content of the view is defined in the body property
    var body: some View {
        
        // Container providing standard settings section spacing and styling
        NavigationSubView(spacing: Constants.SettingsSectionSpacing) {
            
            // Vertical stack for top section (app info display)
            VStack(spacing: 0) {
                // Hidden Easter egg button triggering a haptic vibration
                Button {
                    // Easter egg: triggers a medium vibration feedback when tapped
                    mediumVibration()
                } label: {
                    /*ScanAnimation(size: 70, withBackground: true)
                        .cornerRadius(25)
                        .padding()*/
                } // End of Button label (no visible content)
                
                // Display the operating system name of the device (localized)
                Text(String(format: "informationview_os".localized(), getOSName()))
                    .padding(.bottom, 3) // Add spacing below the OS name text
                // Display the app's version number (localized)
                Text("version".localized() + " \(getAppVersion())")
                    .opacity(0.5) // Make the version text semi-transparent
            } // End of VStack (app info section)
            .padding(.top) // Add top padding above the app info section
            
            
            // Section for contacting support or developer
            CustomSection() {
                
                // Button to compose an email to the app developer
                Button(action: {
                    writeMail(to: "promixitytracker99@gmail.com")
                }) {
                    // Label with envelope icon and "Contact Developer" text (blue background)
                    NavigationLinkLabel(imageName: "envelope.fill", text: "contact_developer", backgroundColor: Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)), isNavLink: false)
                }
                
                /*NavigationLink(destination: ArticleView(article: faqArticle)) {
                    NavigationLinkLabel(imageName: "questionmark.bubble.fill", text: "FAQ", backgroundColor: .purple, isNavLink: true)
                }*/
            } // End of contact section
            
            // Section for app credits (developer and maintainer info)
            CustomSection(header: "credits") {
                
                // Check if developer's website URL is valid
                if let url = URL(string: "https://abrahamjeffrey.com") {
                    // Create a link to the developer's personal website
                    Link(destination: url, label: {
                        // Label with curly braces icon, "Developer" text (green background), and name "Jeffrey Abraham"
                        NavigationLinkLabel(imageName: "curlybraces", text: "developer", backgroundColor: .green, isNavLink: false, status: "Jeffrey Abraham")
                    })
                }
                
                // Button to compose an email to the app maintainer
                Button(action: {
                    writeMail(to: "bluetoothscanner99@gmail.com")
                }) {
                    // Label with person icon and "Maintainer" text (orange background)
                    NavigationLinkLabel(imageName: "person.fill", text: "maintainer", backgroundColor: .orange, isNavLink: false, status: "Jeffrey Abraham")
                }
            } // End of credits section
  
            /*
            CustomSection(header: "copyright") {
                Text("copyright_text")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color("MainColor"))
                    .padding(.vertical)
            }
             */
        } // End of NavigationSubView content
        .navigationBarTitle("", displayMode: .inline) // Set navigation bar title style to inline (no title text)
    } // End of view body
    
    // Opens the default mail application to send an email to the specified address
    func writeMail(to address: String) {
        if let url = URL(string: "mailto:\(address)") { // Prepare the mailto URL
            if #available(iOS 10.0, *) { // Use modern URL open method on iOS 10+
                UIApplication.shared.open(url) // Open the mailto URL using the newer API
            } else {
                UIApplication.shared.openURL(url) // Use the deprecated openURL method for older iOS
            }
        }
    } // End of writeMail function
}

///
private func getAppVersion() -> String {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String // Retrieve the version string from the app bundle
    return "\(appVersion ?? "unknown")" // Return the version or "unknown" if not found
}

// Preview provider for InformationView (for Xcode Canvas previews)
struct Previews_AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Embed InformationView in a NavigationView for preview
            InformationView() // Display InformationView in the preview
        } // End of NavigationView preview wrapper
    } // End of previews property
} // End of PreviewProvider struct
