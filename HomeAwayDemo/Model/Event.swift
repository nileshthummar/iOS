//
//  Event.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import Foundation
struct Events: Codable {
    let events: [Event]?
    enum CodingKeys: String, CodingKey {
        case events = "events"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        events = try values.decodeIfPresent([Event].self, forKey: .events)
    }
}
struct Event : Codable{
    let id: Int
    let title : String
    let datetime_utc : String?
    let vanueDetail : Venue?
    let performers: [Performer]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case datetime_utc = "datetime_utc"
        case vanueDetail = "venue"
        case performers = "performers"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        datetime_utc = try values.decodeIfPresent(String.self, forKey: .datetime_utc)
        vanueDetail = try values.decodeIfPresent(Venue.self, forKey: .vanueDetail)
        performers = try values.decodeIfPresent([Performer].self, forKey: .performers)
    }
}
struct Performer : Codable{
    let image: String?
    enum CodingKeys: String, CodingKey {
        case image = "image"
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        image = try values.decodeIfPresent(String.self, forKey: .image)
    }
}
struct Venue : Codable{
    let city: String?
    let state: String?    
    enum CodingKeys: String, CodingKey {
        case city = "city"
        case state = "state"
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        state = try values.decodeIfPresent(String.self, forKey: .state)
    }    
}

