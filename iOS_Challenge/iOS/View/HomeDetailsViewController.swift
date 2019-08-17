//
//  HomeDetailsViewController.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class HomeDetailsViewController: UIViewController {
    @IBOutlet var viewModel : HomeDetailsViewModel!
    @IBOutlet weak var header:UIView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblLocationline1:UILabel!
    @IBOutlet weak var lblLocationline2:UILabel!
    @IBOutlet weak var lblPhone:UILabel!
    @IBOutlet weak var lblDesc:UILabel!    
    @IBOutlet weak var headerLabel:UILabel!
    private let  offset_HeaderStop:CGFloat = 200.0 ///for scroll animation and show header
    private let  distance_W_LabelHeader:CGFloat = 50.0 ///for scroll animation and show header
    private let  offset_B_LabelHeader:CGFloat = 160.0 ///for scroll animation and show header
    var person : Person?
    {
        didSet {
            viewModel.person = person
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        loadData()
        resetLayout()
    }    
    func loadData() {
        if let url = viewModel.getImageUrl() {
            UIImage.asyncFrom(url: url) { (result) in
                switch result {
                case .success(let image):
                    self.imgView.image = image
                case .error(let error):
                    print(error)
                    self.imgView.image = nil
                }
            }
        } else {
            imgView.image = nil
        }        
        lblDate?.text = viewModel.getDate()
        lblTitle?.text = viewModel.getTitle()
        lblLocationline1?.text = viewModel.getLocation1()
        lblLocationline2?.text = viewModel.getgetLocation2()
        lblPhone?.text =  viewModel.getPhone()
        lblDesc?.text = viewModel.getDesc()
    }
    func resetLayout(){
        let maxWidth = self.view.bounds.width - 40
        var textSize = Utils.getTextSize(lblDate, width: maxWidth)
        var rect =  lblDate.frame
        rect.size.height = textSize.height
        lblDate.frame = rect
        
        textSize = Utils.getTextSize(lblTitle, width: maxWidth)
        rect =  lblTitle.frame
        rect.size.height = textSize.height
        lblTitle.frame = rect
        
        textSize = Utils.getTextSize(lblLocationline1, width: maxWidth)
        rect =  lblLocationline1.frame
        rect.size.height = textSize.height
        lblLocationline1.frame = rect
        
        textSize = Utils.getTextSize(lblLocationline2, width: maxWidth)
        rect =  lblLocationline2.frame
        rect.size.height = textSize.height
        lblLocationline2.frame = rect
        
        textSize = Utils.getTextSize(lblPhone, width: maxWidth)
        rect =  lblPhone.frame
        rect.size.height = textSize.height
        lblPhone.frame = rect
        
        textSize = Utils.getTextSize(lblDesc, width: maxWidth)
        rect =  lblDesc.frame
        rect.size.height = textSize.height
        lblDesc.frame = rect
    }
    func setupNavigation(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
}
extension HomeDetailsViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        var headerTransform = CATransform3DIdentity
        if offset < 0 {
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
        }
        else{
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
        }
        header.layer.transform = headerTransform
        let alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
        headerLabel.alpha = alpha
        if(alpha >= 1)
        {
            headerLabel.alpha = 0
            self.title =  viewModel.getTitle()
            self.navigationController?.navigationBar.isTranslucent = false
        }
        else{
            self.title = ""
            self.navigationController?.navigationBar.isTranslucent = true
        }
    }
}
extension UIViewController {
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
