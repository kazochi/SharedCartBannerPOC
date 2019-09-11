//
//  BannerHandler.swift
//  SharedCartBannerPOC
//
//  Created by Kazuhito Ochiai on 9/10/19.
//  Copyright © 2019 Kazuhito Ochiai. All rights reserved.
//

import UIKit

@objc class SharedCartBannerContainerViewController: UIViewController {
    static let sharedCartDidBecomeActiveNotification = Notification.Name("SharedCartDidBecomeActiveNotification")
    static let sharedCartDidBecomeInactiveNotification = Notification.Name("SharedCartDidBecomeInactiveNotification")
    
    private let viewController: UIViewController
    private let bannerView: UIView
    private var bannerBottomConstraint: NSLayoutConstraint!

    init(viewController: UIViewController) {
        self.viewController = viewController
        bannerView = UIView(frame: .zero)
        bannerView.backgroundColor = .red
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
                                     viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     viewController.view.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)])
        
        isActivated = true
    }
    
    var isActivated: Bool = false {
        didSet {
            guard isActivated != oldValue else {
                return
            }
            if isActivated {
                registerNotifications()
            }
            else {
                deRegisterNotification()
            }
        }
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showBannerView),
                                               name: SharedCartBannerContainerViewController.sharedCartDidBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideBannerView),
                                               name: SharedCartBannerContainerViewController.sharedCartDidBecomeInactiveNotification,
                                               object: nil)
    }
    
    
    private func deRegisterNotification() {
        NotificationCenter.default.removeObserver(self, name: SharedCartBannerContainerViewController.sharedCartDidBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: SharedCartBannerContainerViewController.sharedCartDidBecomeInactiveNotification, object: nil)
    }
    
    
    @objc func showBannerView() {
        guard let bannerContainerView = view else {
            return
        }
        guard bannerView.superview == nil else {
            return
        }
        
        bannerContainerView.addSubview(bannerView)
        
        bannerBottomConstraint = bannerView.topAnchor.constraint(equalTo: bannerContainerView.bottomAnchor)
        NSLayoutConstraint.activate([bannerBottomConstraint,
                                     bannerView.leadingAnchor.constraint(equalTo: bannerContainerView.leadingAnchor),
                                     bannerView.trailingAnchor.constraint(equalTo: bannerContainerView.trailingAnchor)])
        bannerContainerView.setNeedsLayout()
        bannerContainerView.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.bannerBottomConstraint.constant = -(self.bannerView.bounds.size.height + bannerContainerView.layoutMargins.bottom)
            bannerContainerView.setNeedsLayout()
            bannerContainerView.layoutIfNeeded()
        }
        
        var additionalSafeArea = UIEdgeInsets()
        additionalSafeArea.bottom = bannerView.bounds.size.height
        viewController.additionalSafeAreaInsets = additionalSafeArea
    }
    
    
    @objc func hideBannerView() {
        guard let bannerContainerView = view else {
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.bannerBottomConstraint.constant = 0
            bannerContainerView.setNeedsLayout()
            bannerContainerView.layoutIfNeeded()
        }, completion: { _ in
            self.bannerView.removeFromSuperview()
        })
        
        viewController.additionalSafeAreaInsets = .zero
    }
}

