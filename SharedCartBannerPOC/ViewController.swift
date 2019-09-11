//
//  ViewController.swift
//  SharedCartBannerPOC
//
//  Created by Kazuhito Ochiai on 9/10/19.
//  Copyright © 2019 Kazuhito Ochiai. All rights reserved.
//

import UIKit

class ViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    override func loadView() {
        tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        self.view = tableView
    }
    
    var shouldShowSharedCartBanner = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MyViewControllerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            NotificationCenter.default.post(name: SharedCartBannerContainerViewController.sharedCartDidBecomeActiveNotification, object: nil)
        } else if indexPath.row == 1 {
            NotificationCenter.default.post(name: SharedCartBannerContainerViewController.sharedCartDidBecomeInactiveNotification, object: nil)
        } else if indexPath.row == 2 {
            
        }
    }
}
