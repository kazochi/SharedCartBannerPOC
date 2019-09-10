//
//  BannerHandler.swift
//  SharedCartBannerPOC
//
//  Created by Kazuhito Ochiai on 9/10/19.
//  Copyright © 2019 Kazuhito Ochiai. All rights reserved.
//

import UIKit

@objc class SharedCartBannerHandler: NSObject {
    static let sharedCartDidBecomeActiveNotification = Notification.Name("SharedCartDidBecomeActiveNotification")
    static let sharedCartDidBecomeInactiveNotification = Notification.Name("SharedCartDidBecomeInactiveNotification")

    private let bannerParentView: UIView
    private let bannerView: UIView
    private var contentInsentAdjustedScrollViews: [UIScrollView] = []
    private var bannerBottomConstraint: NSLayoutConstraint!

    init(bannerParentView: UIView, bannerView: UIView) {
        self.bannerParentView = bannerParentView
        self.bannerView = bannerView
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
        guard bannerView.superview == nil else {
            return
        }
        
        self.bannerParentView.addSubview(bannerView)
        
        bannerBottomConstraint = bannerView.topAnchor.constraint(equalTo: bannerParentView.bottomAnchor)
        NSLayoutConstraint.activate([bannerBottomConstraint,
                                     bannerView.leadingAnchor.constraint(equalTo: bannerParentView.leadingAnchor),
                                     bannerView.trailingAnchor.constraint(equalTo: bannerParentView.trailingAnchor)])
        bannerParentView.setNeedsLayout()
        bannerParentView.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.bannerBottomConstraint.constant = -(self.bannerView.bounds.size.height + self.bannerParentView.layoutMargins.bottom)
            self.bannerParentView.setNeedsLayout()
            self.bannerParentView.layoutIfNeeded()
        }
        adjustContentInset(view: bannerParentView)
    }
    
    
    @objc func hideBannerView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.bannerBottomConstraint.constant = 0
            self.bannerParentView.setNeedsLayout()
            self.bannerParentView.layoutIfNeeded()
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
            let scrollViewRectInParentView = scrollView.convert(scrollView.frame, to: self.bannerParentView)
            let bannerViewRectInParentView = self.bannerView.convert(self.bannerView.bounds, to: self.bannerParentView)
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

