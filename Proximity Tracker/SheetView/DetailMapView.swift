//
//  DetailMapView.swift
//  Proximity Tracker
//
//  Created by user238598 on 4/2/24.
//

struct DetailMapView: View {
    // Section showing a small map preview and navigating to a full map of tracker locations
    
    @ObservedObject var tracker: BaseDevice    // The tracker device whose locations are shown on the map
    @State var smallMapFinishedLoading = false    // Tracks whether the small map preview finished loading
    
    var body: some View {
        Group {
            if let detections = tracker.detectionEvents?.array as? [DetectionEvent], !tracker.ignore {
                // If there are recorded detection events and the tracker is not ignored, show map content
                
                let connections = detections.compactMap({$0.location}).map({CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)})
                // Coordinates representing sequential connections between detections
                
                let coordinates = detectionToCoordinates(detectionEvents: detections)
                // Clustered location data for detection events
                
                let annotations = coordinates.map({MapAnnotation(clusteredLocation: $0)})
                // Create map annotations from each clustered location
                
                if annotations.count > 0 {
                    // If we have at least one annotation, show the map preview
                    NavigationLink {
                        MapView(annotations: annotations, connections: connections, mapFinishedLoading: .constant(true))
                            .ignoresSafeArea(.all, edges: [.horizontal, .bottom])
                            .navigationTitle("tracker_locations")
                            .navigationBarTitleDisplayMode(.inline)
                            .background(ProgressView())
                    } label: {
                        MapView(annotations: annotations, connections: connections, mapFinishedLoading: $smallMapFinishedLoading)
                            .overlay(
                                ZStack {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            ZStack {
                                                Blur(style: .systemUltraThinMaterialDark)
                                                    .cornerRadius(10)
                                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                    .foregroundColor(.white)
                                            }
                                            .frame(width: 30, height: 30, alignment: .center)
                                            .padding()
                                        }
                                        Spacer()
                                    }
                                })
                            .background(ProgressView())
                            .allowsHitTesting(false)    // Make the preview map non-interactive
                            .compositingGroup()
                            .frame(height: 200)    // Height of the preview map
                    }
                        .modifier(FormModifierNoPadding(showShadow: !smallMapFinishedLoading))
                        .animation(.easeInOut, value: !smallMapFinishedLoading)
                } else {
                    MapPlaceholderView(isTrackerIgnored: tracker.ignore)
                }
            } else {
                MapPlaceholderView(isTrackerIgnored: tracker.ignore)
            }
        }
        .padding(.horizontal)
    }
}

struct MapPlaceholderView: View {
    // A placeholder view to show when map data is unavailable
    let isTrackerIgnored: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "map.fill")
                .font(.largeTitle)
                .centered()
                .lowerOpacity(darkModeAsWell: true)
                .foregroundColor(.accentColor)
                .padding(.bottom, 5)
            HStack {
                Spacer()
                Text(isTrackerIgnored ? "map_unavailable_ignored" : "map_unavailable_no_locations")
                    .bold()
                    // .foregroundColor(formHeaderColor)
                    .centered()
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            Spacer()
        }
        .padding(.vertical)
        .modifier(FormModifier())
    }
}

/// Extracts the coordinates of detection events to ClusteredLocation
func detectionToCoordinates(detectionEvents: [DetectionEvent]) -> [ClusteredLocation] {
    var processedLocations = [NSManagedObjectID : ClusteredLocation]()
    for event in detectionEvents {
        if let location = event.location, let time = event.time {
            if processedLocations[location.objectID] == nil {
                let cllocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                let data = ClusteredLocation(location: cllocation, startDate: time, endDate: time, worstAccuracy: location.accuracy)
                processedLocations[location.objectID] = data
            } else {
                processedLocations[location.objectID]?.endDate = time
                if location.accuracy > processedLocations[location.objectID]?.worstAccuracy ?? 0 {
                    processedLocations[location.objectID]?.worstAccuracy = location.accuracy
                }
            }
        }
    }
    return processedLocations.values.map({$0})
}

/// Struct to store data of the locations shown on the map
struct ClusteredLocation {
    let location: CLLocationCoordinate2D
    let startDate: Date
    var endDate: Date
    var worstAccuracy: Double
}

struct Previews_DetailMapView_Previews: PreviewProvider {
    static var previews: some View {
        
        let vc = PersistenceController.sharedInstance.container.viewContext
        
        let device = BaseDevice(context: vc)
        device.setType(type: .AirTag)
        device.firstSeen = Date()
        device.lastSeen = Date()
        
        let detectionEvent = DetectionEvent(context: vc)
        
        detectionEvent.time = device.lastSeen
        detectionEvent.baseDevice = device
        
        let location = Location(context: vc)
        
        location.latitude = 52
        location.longitude = 8
        location.accuracy = 1
        
        detectionEvent.location = location
        
        try? vc.save()
        
        return VStack {
            DetailMapView(tracker: device)
                .environment(\.managedObjectContext, vc)
        }
    }
}
