//
//  DetailViewModel.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class DetailViewModel: NSObject {
    var event: Event!
    // get current Event title
    func getTitle() -> String {
        return event.title
    }
    // get current Event Image url
    func getImageUrl() -> String {
        if ((event.performers?.first?.image) != nil){
            return event.performers?.first?.image ?? ""
        }
        return ""
    }
    // get current Event Vanue City,State
    func getLocation() -> String {
        return "\(String(describing: event.vanueDetail?.city ?? "--")) , " + "\(String(describing: event.vanueDetail?.state ?? "--"))"
    }
    // get current Event Time
    func getTime() -> String {
        return Utils.format(date: event.datetime_utc ?? "")
    }
}
