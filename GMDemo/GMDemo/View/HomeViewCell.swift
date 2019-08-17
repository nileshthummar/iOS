//
//  HomeViewCell.swift
//  GMDemo
//
//  Created by Nilesh on 8/8/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class HomeViewCell: UITableViewCell {
    @IBOutlet weak var lblName:UILabel! //Auther Name
    @IBOutlet weak var lblTime:UILabel! //Auther date
    @IBOutlet weak var lblMessage:UILabel! //commit message
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1        
    }
    var commit : GMCommit? {
        didSet {            
            guard let commit = commit else {
                return
            }
            lblName?.text = commit.commit.author.name
            lblTime?.text = Date.format(date: commit.commit.author.date)
            lblMessage?.text = commit.commit.message
            
        }
    }
}
