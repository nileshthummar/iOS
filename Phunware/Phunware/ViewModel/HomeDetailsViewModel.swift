//
//  HomeDetailsViewModel.swift
//  Phunware
//
//  Created by Nilesh on 6/17/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class HomeDetailsViewModel: NSObject {
    var person : Person?
    // get current person date
    func getDate() -> String {
        return Utils.format(date: person?.date ?? "")
    }
    // get current person title
    func getTitle() -> String {
        return person?.title ?? ""
    }
    // get current person Location 1
    func getLocation1() -> String {
        return person?.locationline1 ?? ""
    }
    // get current person Location 2
    func getgetLocation2() -> String {
        return person?.locationline2 ?? ""
    }
    // get current person Phone
    func getPhone() -> String {
        return person?.phone ?? ""
    }
    // get current person Description
    func getDesc() -> String {
        return person?.desc ?? ""
    }
    // get current person imageURL
    func getImageUrl() -> URL? {
        return person?.image
    }
}
