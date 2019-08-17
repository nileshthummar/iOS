//
//  HomeViewModel.swift
//  GMDemo
//
//  Created by Nilesh on 8/8/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class HomeViewModel: NSObject {
    private weak var dataSource : GenericDataSource<GMCommit>?
    var onErrorHandling : ((Error?) -> Void)? //common error handling
    init( dataSource : GenericDataSource<GMCommit>?) {
        self.dataSource = dataSource
    }
    ///will fetch Data from API and return to View
    func fetchData(completion:@escaping () -> ()){
        CommitAPI.shared.allCommitsAsync { (result) in
            switch result {
            case .success(let persons):
                self.dataSource?.data.value = persons
                completion()
                
            case .failure(let error):
                print("Failed to fetch Data:", error as Any)                
            }
        }
    }
    
}
