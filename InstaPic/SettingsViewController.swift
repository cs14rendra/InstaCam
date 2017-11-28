//
//  SettingsViewController.swift
//  InstaPic
//
//  Created by surendra kumar on 6/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func rateus(_ sender: AnyObject) {
        let url : URL = URL(string: "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=7")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    @IBAction func share(_ sender: AnyObject) {
        let acivity1 = DESCRIPTION
        let activity2 = APP_URL
        let activity = UIActivityViewController(activityItems: [acivity1,activity2], applicationActivities: nil)
        
        
        activity.popoverPresentationController?.sourceView = self.view
        
        present(activity, animated: true, completion: nil)
        
    }
    

    @IBAction func mini(_ sender: Any) {
        let url : URL = URL(string: "https://itunes.apple.com/us/app/mini-for-facebook-with-lock-feature/id1088589740?mt=8")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func search(_ sender: Any) {
        
        let url : URL = URL(string: "https://itunes.apple.com/us/app/universal-image-search-pro/id1073353001?mt=8")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
}
