//
//  Utils.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class Utils: NSObject {
    /**
     Standard date formatter to convert UTC times into user friendly readable dates
     */
    /// date": "2015-10-10T04:00:00.000Z",
    static func format(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
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
/*
let movies = [
    "The Phantom Menace",
    "Attack of the Clones",
    "Revenge of the Sith",
    "A New Hope",
    "The Empire Strikes Back",
    "Return of the Jedi"
]

for i in 0 ..< movies.count {
    print("Episode \(i + 1): \(movies[i])")
}
func isDiagonalMatrix(matrix: [[Int]]) -> Bool {
    
    for var x in 0..<matrix.count {
        for var y in 0..<matrix[x].count {
            if(x != y && Int(matrix[x][y]) != 0)
            {
                return false
            }
        }
        
    }
    return true
}
*/
