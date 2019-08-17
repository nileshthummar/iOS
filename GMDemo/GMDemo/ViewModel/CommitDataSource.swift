//
//  EventDataSource.swift
//  GMDemo
//
//  Created by Nilesh on 8/8/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import Foundation
import UIKit

class GenericDataSource<T> : NSObject {
    var data: DynamicValue<[T]> = DynamicValue([])
}
///MARK Collection View DataSorce
class CommitDataSource : GenericDataSource<GMCommit>, UITableViewDataSource {
    //return number of cell base on total number of commits return from API.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.value.count
    }
    ///return custom reusable cell for home tableview.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHome", for: indexPath) as! HomeViewCell
        let commit = self.data.value[indexPath.row]
        cell.commit = commit
        return cell

    }
    //Automatic cell hight for fit all long message text in cell.
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return UITableView.automaticDimension;
    }
}
