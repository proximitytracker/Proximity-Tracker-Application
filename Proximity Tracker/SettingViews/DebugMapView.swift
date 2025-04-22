//
//  DebugMapView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

import SwiftUI
import CoreLocation

struct DebugMapView: View {    // Debug view to display recorded locations on a map
    
    @FetchRequest( // Fetch all Location entities (no filter/predicate)
        sortDescriptors: []
    ) var elems: FetchedResults<Location> // Results of the fetch: list of Location records
    
    var body: some View { // Defines the map view content
        let connections = elems.map({CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}) // Extract coordinates from each Location record
        
        let annotations = connections.map({MapAnnotation(clusteredLocation: ClusteredLocation(location: $0, startDate: .distantPast, endDate: .distantPast, worstAccuracy: 0))}) // Create map annotations for each coordinate
        
        MapView(annotations: annotations, connections: [], mapFinishedLoading: .constant(true)) // Display the map with the collected annotations
    }
}
