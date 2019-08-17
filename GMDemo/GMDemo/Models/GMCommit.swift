//
//  Persons.swift
//  GMDemo
//
//  Created by Nilesh on 8/8/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//
import UIKit
// MARK: - GMCommit
struct GMCommit: Codable {
    let commit: Commit
    enum CodingKeys: String, CodingKey {
        case commit
    }
}

// MARK: - Commit
struct Commit: Codable {
    let author: Author
    let message: String
    enum CodingKeys: String, CodingKey {
        case author, message
    }
}

// MARK: - Author
struct Author: Codable {
    let name, email, date: String
    enum CodingKeys: String, CodingKey {
        case name, email,date
    }
}

