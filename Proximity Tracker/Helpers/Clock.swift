//
//  Clock.swift
//  Tag Scanner
//
//  Created by Jeffrey Abraham on 26.05.22.
//

import Foundation
import SwiftUI


/// Class to represent the current date
class Clock : NSObject, ObservableObject {
    
    /// The current date.
    @Published var currentDate = Date()
    
    /// The timer to refresh the date
    private var timer = Timer.init()
    
    /// The shared instance.
    static var sharedInstance = Clock()
    
    /// The private initializer
    private override init() {
        
        /// Initi NSObject
        super.init()

        /// Fire timer every second and refresh date
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.objectWillChange.send() // Notify observers that something is changing
            self.currentDate = Date() // Update the current date to trigger UI refreshes
        }
    }
}
