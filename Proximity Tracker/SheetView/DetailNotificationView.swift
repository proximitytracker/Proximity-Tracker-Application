import SwiftUI

struct DetailNotificationsView: View {
    // Section of the tracker detail showing recent notifications and false alarm controls
    
    @ObservedObject var tracker: BaseDevice    // The tracker device whose notifications to display
    @ObservedObject var clock = Clock.sharedInstance    // Shared clock to get current time
    
    var body: some View {
        
        let notifications = (tracker.notifications?.array as? [TrackerNotification] ?? []).reversed()
        // Get the tracker's notifications, reversed to show newest first
        
        if !notifications.isEmpty && !tracker.ignore {    // If there are notifications and tracker is not ignored
            CustomSection(header: "notifications", footer: "false_alarm_description") {    // Section with 'Notifications' header and a footer description about false alarms
                ForEach(notifications, id: \.self) { notification in
                    if let time = notification.time {
                        HStack {
                            Text(getSimpleSecondsText(seconds: Int(-time.timeIntervalSince(clock.currentDate)), longerDate: false))
                                // Show how long ago (in seconds) this notification was recorded, as a human-readable time difference
                                .foregroundColor(Color("MainColor"))    // Use main color for the time text
                                .frame(height: Constants.SettingsLabelHeight)    // Ensure consistent height for the label
                            
                            Spacer()
                            
                            FalseAlarmButton(notification: notification)    // Button to mark/unmark this notification as a false alarm
                        }
                    }
                    if notification != notifications.last {
                        CustomDivider()    // Divider between notifications
                    }
                }
            }
        }
    }
}

struct FalseAlarmButton: View {
    // Button view that toggles the 'false alarm' status of a notification
    @ObservedObject var notification: TrackerNotification    // The notification object this button controls
    
    let persistenceController = PersistenceController.sharedInstance    // Shared persistence controller for database updates
    
    var body: some View {
        Button {
            mediumVibration()    // Provide haptic feedback on button press
            
            let id = notification.objectID    // Capture the notification's object ID for use in background context
            
            persistenceController.modifyDatabaseBackground { context in
                // Perform database modification on a background context
                if let notification = context.object(with: id) as? TrackerNotification {
                    notification.falseAlarm.toggle()    // Toggle the falseAlarm flag for this notification
                }
            }
        } label: {
            if notification.falseAlarm {
                Text("unmark_false_alarm")    // If already marked as false alarm, offer to unmark
            } else {
                Text("mark_false_alarm")    // If not marked, offer to mark as false alarm
            }
        }
        .lineLimit(1)    // Ensure the button label is one line
    }
}
