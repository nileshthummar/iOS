//
//  HomeViewModel.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class HomeViewModel: NSObject {
    private weak var dataSource : GenericDataSource<Person>?
    var onErrorHandling : ((ErrorResult?) -> Void)? //common error handling
    init( dataSource : GenericDataSource<Person>?) {
        self.dataSource = dataSource
    }
    ///will fetch Data from API and return to View
    func fetchData(completion:@escaping () -> ()){
        PersonAPI.shared.allPersonsAsync { (result) in
            switch result {
            case .success(let persons):
                self.dataSource?.data.value = persons
                completion()
                
            case .error(let error):
                print("Failed to fetch Data:", error as Any)
            }
        }
    }
    
}
