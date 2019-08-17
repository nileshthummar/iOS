//
//  ErrorResult.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import Foundation

enum ErrorResult: Error {
    case network(string: String)
    case parser(string: String)
    case custom(string: String)
}
