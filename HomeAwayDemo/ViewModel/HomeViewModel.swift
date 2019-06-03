//
//  HomeViewModel.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//
import UIKit
class HomeViewModel: NSObject {
    @IBOutlet var eventsClient : EventsClient!
    var events : [Event]?
    ///get Events from Service and return to ViewController
    func fetchEvents(searchText: String, completion:@escaping () -> ()){
        eventsClient.fetchEvents(searchText: searchText) {(events, err) in
            if (err != nil && err!.count > 0){
                print("Failed to fetch Data:", err as Any)
                return
            }
            self.events = events?.events
            completion()
        }           
    }
    /// For return number of total Events
    func numberOfRowsInSection(section: Int) -> Int {
        return events?.count ?? 0;
    }
    //For return Event at Indexpath
    func eventForRowAtIndexPath(indexPath:IndexPath) -> Event {
        return events![indexPath.row]
    }
}
