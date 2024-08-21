//
//  CalendarManager.swift
//  KaizenOS
//
//  Created by Avneet Singh on 6/13/24.
//

import Foundation
import EventKit

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    
    func addEventWithPermission(title: String, startDate: Date, endDate: Date) {
        eventStore.requestFullAccessToEvents { granted, error in
            if granted && error == nil {
                self.addEvent(title: title, startDate: startDate, endDate: endDate)
            } else {
                print("Failed to get access with error: \(String(describing: error))")
            }
        }
    }
    
    private func addEvent(title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event saved successfully")
        } catch let error as NSError {
            print("Failed to save event with error: \(error)")
        }
    }
    
    
}
