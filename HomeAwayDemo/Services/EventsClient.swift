//
//  EventsClient.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit
import Alamofire
var request:DataRequest?
class EventsClient: NSObject {
    ///for fetch Events from seatgeek API    
    ///Full API documentation is available at http://platform.seatgeek.com/#events
    func fetchEvents(searchText: String,completion: @escaping (Events?, String?) -> ()){
        request?.cancel()
        var encodedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        encodedSearchText = encodedSearchText.replacingOccurrences(of: " ", with: "+")
        encodedSearchText = encodedSearchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        // fetch the data        
        let urlString = "https://api.seatgeek.com/2/events?client_id="+AppConstants.kSeatgeekClientID+"&q="+encodedSearchText
        guard let url = URL(string: urlString) else {
            return }
        request =  Alamofire.request(url, method: .get, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseString { (response) in
                switch response.result {
                case .success:
                    print("success")
                    if response.error != nil {
                        print(response.error?.localizedDescription as Any)
                        completion(nil, response.error?.localizedDescription)
                    }
                    guard let data = response.data else {
                        completion(nil, "Something went wrong!")
                        return
                    }
                    do {
                        let response = try JSONDecoder().decode(Events?.self, from: data)
                        completion(response,"")                        
                        
                    } catch let jsonError {
                        print(jsonError)
                        completion(nil,jsonError.localizedDescription)
                    }
                case .failure(let error):
                    guard let data = response.data else {
                        completion(nil, "Something went wrong!")
                        return
                    }
                    do {
                        let jsonMessage:NSDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                        if let val = jsonMessage["error"] {
                            print(val)
                            completion(nil,val as? String)
                        }
                        else {
                            completion (nil,error.localizedDescription)
                        }
                    } catch let jsonError {
                        print(jsonError)
                        completion(nil,jsonError.localizedDescription)
                    }                    
                }
        }
    }

}
