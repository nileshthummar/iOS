//
//  PersonAPI.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class PersonAPI: NSObject {
    let service: Service
    static let shared = PersonAPI()
    
    convenience override init() {
        self.init(service: NetworkService())
    }
    
    init(service: Service) {
        self.service = service
    }
    
    func allPersonsAsync(request: Requests = APIRequests.persons, _ completion: @escaping (Result<[Person]>) -> Void) {
        service.get(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let persons: [Person] = try JSONDecoder().decode([Person].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(persons))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.error(error))
                    }
                }
            case .error(let error):
                DispatchQueue.main.async {
                    completion(.error(error))
                }
            }
        }
    }
}
enum APIRequests: String, Requests {
    case persons = "https://raw.githubusercontent.com/phunware-services/dev-interview-homework/master/feed.json"
    
    var url: URL {
        return URL(string: rawValue)!
    }
}
enum APIError: Error {
    case noPersons
}

