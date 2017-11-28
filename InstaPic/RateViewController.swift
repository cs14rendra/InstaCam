//
//  RateViewController.swift
//  InstaPic
//
//  Created by surendra kumar on 7/6/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit

class RateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        IAPHelper.sharedInstance.delegate = self
    }

    @IBAction func purchaseButton(_ sender: Any) {
        IAPHelper.sharedInstance.requestProductInfo()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func rateBUtton(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isupgraded")
        //RATE CODE
        let url : URL = URL(string: "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=7")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension RateViewController : IAPHelperDelegate{
    func purchasedItem() {
        UserDefaults.standard.set(true, forKey: "isupgraded")
    }
}
