//
//  BannerHandler.swift
//  SharedCartBannerPOC
//
//  Created by Kazuhito Ochiai on 9/10/19.
//  Copyright © 2019 Kazuhito Ochiai. All rights reserved.
//

import UIKit

@objc class SharedCartBannerHandler: NSObject {
    static let shared = SharedCartBannerHandler()
    
    static let sharedCartDidBecomeActiveNotification = Notification.Name("SharedCartDidBecomeActiveNotification")
    static let sharedCartDidBecomeInactiveNotification = Notification.Name("SharedCartDidBecomeInactiveNotification")

    var bannerContainerView: UIView? {
        willSet {
            hideBannerView()
        }
    }
    
    private let bannerView: UIView
    private var contentInsentAdjustedScrollViews: [UIScrollView] = []
    private var bannerBottomConstraint: NSLayoutConstraint!

    override init() {
        bannerView = UIView(frame: .zero)
        bannerView.backgroundColor = .red
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
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
                                               name: SharedCartBannerHandler.sharedCartDidBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideBannerView),
                                               name: SharedCartBannerHandler.sharedCartDidBecomeInactiveNotification,
                                               object: nil)
    }
    
    
    private func deRegisterNotification() {
        NotificationCenter.default.removeObserver(self, name: SharedCartBannerHandler.sharedCartDidBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: SharedCartBannerHandler.sharedCartDidBecomeInactiveNotification, object: nil)
    }
    
    
    @objc func showBannerView() {
        guard let bannerContainerView = bannerContainerView else {
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
        adjustContentInset(view: bannerContainerView)
    }
    
    
    @objc func hideBannerView() {
        guard let bannerContainerView = bannerContainerView else {
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.bannerBottomConstraint.constant = 0
            bannerContainerView.setNeedsLayout()
            bannerContainerView.layoutIfNeeded()
        }, completion: { _ in
            self.bannerView.removeFromSuperview()
            
            for scrollView in self.contentInsentAdjustedScrollViews {
                // What if scrollView has non-zero content inset?
                scrollView.contentInset.bottom = 0
            }
        })
    }
    
    
    private func adjustContentInset(view: UIView) {
        if let scrollView = view as? UIScrollView {
            let scrollViewRectInParentView = scrollView.convert(scrollView.frame, to: self.bannerContainerView)
            let bannerViewRectInParentView = self.bannerView.convert(self.bannerView.bounds, to: self.bannerContainerView)
            let overwrappedRect = bannerViewRectInParentView.intersection(scrollViewRectInParentView)
            scrollView.contentInset.bottom = overwrappedRect.size.height
            contentInsentAdjustedScrollViews.append(scrollView)
        }
        // Maybe overkill to go recursive entire view hierarchy
        for subView in view.subviews {
            adjustContentInset(view: subView)
        }
    }
}

