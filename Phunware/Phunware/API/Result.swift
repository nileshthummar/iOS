//
//  Result.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(Error)
}
