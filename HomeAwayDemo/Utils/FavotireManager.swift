//
//  FavotireManager.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//
//Class to sve the favorite items to the user defaults.
//If thousands of recoreds replace this with SQL/realm or add capacity

import UIKit

class FavotireManager: NSObject {
    static let kFavoriteDefaultKey = "favoriteDefaults"
    static let shared = FavotireManager()
    var dictFavorite = Dictionary<Int, Any>()
    
    override init() {
        super.init()
        loadFromUserDefault()
    }
    /**
    Load the items into the Dictionary from the defaults
    */
    func loadFromUserDefault() {
        if let favData = UserDefaults.standard.data(forKey: FavotireManager.kFavoriteDefaultKey) {
            if let favorites = (try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self], from: favData)) as? NSDictionary {
                dictFavorite = favorites as! [Int : Any]
            }
        }
    }
    /**
     save the items to the defaults
     */
    func save() {
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: dictFavorite, requiringSecureCoding: true)
            UserDefaults.standard.set(encodedData, forKey: FavotireManager.kFavoriteDefaultKey)
            UserDefaults.standard.synchronize()
        } catch {
            print(error)
        }
       
    }

    
    /**
     Adds a key to the map then calls save
     */
    func add(id: Int) {
        dictFavorite[id] = true //the bool is just a placeholder to take advantage of the map
        save()
    }
    
    /**
     Removes a key from the map then calls save
     */
    func remove(id: Int) {
        dictFavorite.removeValue(forKey: id)
        save()
    }
    /**
     Checks to see if an id key is in the map
     */
    func check(id: Int) -> Bool {
        if let _ = dictFavorite[id] {
            return true
        }
        return false
    }
}
