//
//  Service.swift
//  GMDemo
//
//  Created by Nilesh on 8/8/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import Foundation

// MARK: - Networking - if you want to create your own service layer

protocol Requests {
    var url: URL { get }
}

protocol Service {
    
    func get(request: Requests, completion: @escaping (Result<Data,Error>) -> Void)
}

final class NetworkService: Service {
    func get(request: Requests, completion: @escaping (Result<Data,Error>) -> Void) {
        ////
        var request = URLRequest(url: request.url)        
        if let reachability = Reachability(), !reachability.isReachable {
            request.cachePolicy = .returnCacheDataDontLoad
        }
        ////
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(ServiceError.invalidData))
                return
            }
            completion(.success(data))
        }.resume()
    }
}

enum ServiceError: Error {
    case invalidData
}
