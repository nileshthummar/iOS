//
//  Utils.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class Utils: NSObject {
    /**
     Standard date formatter to convert UTC times into user friendly readable dates
     */
    static func format(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "E, d MMM yyyy HH:mm a"
        if let date = dateFormatter.date(from: date) {
            return dateFormatterPrint.string(from: date)
        } else {
            print("There was an error decoding the string")            
        }
        return ""
    }
    
    /**
     Caculates the textSize (mainly the height) of a label based on its font and max width it can draw in.
     */
    static func getTextSize(_ label: UILabel, width: CGFloat) -> CGSize {
        let font = label.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        guard let text = label.text else {return CGSize(width: 0, height: 0)}
        return (text as NSString).boundingRect(with: CGSize(width: width, height: 0), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
    
}
