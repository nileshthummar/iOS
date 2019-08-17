//
//  DateExtensions.swift
//  GMDemo
//
//  Created by Nilesh on 8/8/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import Foundation

extension Date {
    //Date format to "E, d MMM yyyy HH:mm a" for easy to read.
    static func format(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let date = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "E, d MMM yyyy HH:mm a"
            return dateFormatter.string(from: date)
        } else {
            print("There was an error decoding the string")
        }
        
        return ""
    }
}
