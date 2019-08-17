//
//  PersonAPI.swift
//  GMDemo
//
//  Created by Nilesh on 8/8/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class CommitAPI: NSObject {
    let service: Service
    static let shared = CommitAPI()
    
    convenience override init() {
        self.init(service: NetworkService())
    }
    
    init(service: Service) {
        self.service = service
    }
    
    func allCommitsAsync(request: Requests = APIRequests.commits, _ completion: @escaping (Result<[GMCommit],Error>) -> Void) {
        service.get(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let commits: [GMCommit] = try JSONDecoder().decode([GMCommit].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(commits))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

enum APIRequests: String, Requests {
    case commits = "https://api.github.com/repos/nileshthummar/iOS-Coding-Challenge/commits" //temp nilesh
    
    var url: URL {
        return URL(string: rawValue)!
    }
}
enum APIError: Error {
    case noPersons
}

