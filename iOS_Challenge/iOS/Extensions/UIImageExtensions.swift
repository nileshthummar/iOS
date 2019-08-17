//
//  UIImageExtensions.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//


import UIKit

enum UIImageError: Error {
    case invalidData
}

struct ImageRequest: Requests {
    let url: URL
}

extension UIImage {
    /// Loads an UIImage from internet asynchronously
    static func asyncFrom(url: URL, service: Service = NetworkService(), _ completion: @escaping (Result<UIImage>) -> Void) {
        service.get(request: ImageRequest(url: url)) { result in
            switch result {
            case .success(let data):
                asyncFrom(data: data, completion)
            case .error(let error):
                completion(.error(error))
            }
        }
    }
    private static func asyncFrom(data: Data, _ completion: @escaping (Result<UIImage>) -> Void) {
        DispatchQueue.global(qos: .default).async {
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.error(UIImageError.invalidData))
                }
            }
        }
    }
}
