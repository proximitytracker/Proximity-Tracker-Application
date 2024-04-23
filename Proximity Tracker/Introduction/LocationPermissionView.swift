//
//  LocationPermissionView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI

struct LocationPermissionView: View {
    
    @ObservedObject var locationManager = LocationManager.sharedInstance
    @ObservedObject var settings = Settings.sharedInstance
    var body: some View {
        
        let canProceed = locationManager.permissionSet
        
        PermissionView(title: "location_access", symbol: "mappin.circle.fill", subtitle: "location_access_description", action: {
            
            let authorizationStatus = locationManager.locationManager?.authorizationStatus ?? .notDetermined
            let authorizationAccuracy = locationManager.locationManager?.accuracyAuthorization ?? .none
            
            if(canProceed) {
                IntroducationViewController.sharedInstance.canProceed = true
            }
            if authorizationStatus == .notDetermined {
                locationManager.requestWhenInUse()
            } else if(locationManager.locationManager?.authorizationStatus == .denied || locationManager.locationManager?.authorizationStatus == .restricted) {
                openAppSettings()
            }
            
            if authorizationStatus == .authorizedWhenInUse && authorizationAccuracy != .fullAccuracy {
                openAppSettings()
            }
            
        }, canSkip: true) {
            /* Work on this later */
            //LocationAlwaysPermissionView()
            
            if(settings.appLaunchedBefore) {
                IntroductionDoneView()
            }else {
                IntroductionDoneView()
            }
        }
        .onChange(of: canProceed) { oldValue, newValue in
            IntroducationViewController.sharedInstance.canProceed = true
        }
    }
}

struct Previews_LocationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        LocationPermissionView()
    }
}
