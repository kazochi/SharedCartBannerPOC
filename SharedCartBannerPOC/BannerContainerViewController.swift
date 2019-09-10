//
//  BannerContainerViewController.swift
//  SharedCartBannerPOC
//
//  Created by Kazuhito Ochiai on 9/10/19.
//  Copyright © 2019 Kazuhito Ochiai. All rights reserved.
//

import UIKit

protocol SharedCartBannerPresentable : UIViewController {
    var shouldShowSharedCartBanner: Bool { get }
}


class BannerContainerViewController : UIViewController {
    var contentViewController: SharedCartBannerPresentable!
    var bannerHandler: SharedCartBannerHandler?
    var bannerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerHandler = SharedCartBannerHandler.shared
        bannerHandler?.bannerContainerView = view
        contentViewController = ViewController()
        bannerHandler?.isActivated = contentViewController!.shouldShowSharedCartBanner
        setUpContentView()
    }
    
    
    private func setUpContentView() {
        
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
                                     contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     contentViewController.view.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)])
    }
}
