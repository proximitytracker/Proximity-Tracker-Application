//
//  DetailMoreView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

struct DetailMoreView: View {
    // Section with additional actions like NFC scan and support website
    
    @ObservedObject var tracker: BaseDevice    // The tracker device for which to show additional options
    @StateObject var nfcReader = NFCReader.sharedInstance    // NFC reader singleton for scanning NFC tags
    
    var body: some View {
        
        let constants = tracker.getType.constants
        // Shortcut to tracker's type-specific constants
        
        let nfcSupport = constants.supportsNFC && !isiPad()
        // Determine if NFC scanning is supported for this tracker (and not on iPad)
        
        if (nfcSupport || constants.supportURL != nil) {
            CustomSection(header: "more", footer: "more_trackerdetailview_description") {
                let color = Color(#colorLiteral(red: 1, green: 0.6991065145, blue: 0.003071677405, alpha: 1))
                // A specific shade of orange color for NFC scan button background
                
                Group {
                    if nfcSupport {
                        Button {
                            nfcReader.scan(infoMessage: String(format: "nfc_description".localized(), tracker.getName) )
                            // Initiate NFC scan with an info message including the tracker's name
                        } label: {
                            NavigationLinkLabel(imageName: "person.fill", text: "scan_nfc", backgroundColor: color, isNavLink: true)
                            // Label for NFC scan option with person icon
                        }
                        
                        if constants.supportURL != nil {
                            CustomDivider()    // Divider between NFC and website options
                        }
                    }
                    
                    if constants.supportURL != nil {
                        Button {
                            if let urlString = constants.supportURL, let url = URL(string: urlString) {
                                openURL(url: url)    // Open the support URL in default browser
                            }
                        } label: {
                            NavigationLinkLabel(imageName: "info", text: "website_manufacturer", backgroundColor: .green, isNavLink: false)
                            // Label for opening the manufacturer's support website
                        }
                    }
                }
            }
        }
    }
}

struct Previews_TrackerInfoView_Previews: PreviewProvider {
    static var previews: some View {
        
        let vc = PersistenceController.sharedInstance.container.viewContext
        
        let device = BaseDevice(context: vc)
        device.setType(type: .AirTag)
        device.firstSeen = Date()
        device.lastSeen = Date()
        
        try? vc.save()
        
        return NavigationView {
            TrackerDetailView(tracker: device, bluetoothData: BluetoothTempData(identifier: UUID().uuidString))
                .environment(\.managedObjectContext, vc)
        }
    }
}
