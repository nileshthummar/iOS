//
//  Persons.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//
import UIKit
struct Person: Codable {
    let id: Double? // A uniq id
    let desc: String? // person description
    let title: String? // title
    let timestamp: String? // timestamp
    let image: URL? // A URL pointing to a remote image
    let phone: String? // person phone number
    let date: String? // date
    let locationline1: String? // address line 1
    let locationline2: String? // address line 2
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case desc = "description"
        case title = "title"
        case timestamp = "timestamp"
        case image = "image"
        case phone = "phone"
        case date = "date"
        case locationline1 = "locationline1"
        case locationline2 = "locationline2"
    }
}
