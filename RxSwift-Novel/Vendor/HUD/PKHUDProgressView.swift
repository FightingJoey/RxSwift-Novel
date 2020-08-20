//
//  PKHUDProgressView.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/12/15.
//  Copyright (c) 2016 NSExceptional. All rights reserved.
//  Licensed under the MIT license.
//

import UIKit

@objc public protocol PKHUDAnimating {
    func startAnimation()
    @objc optional func stopAnimation()
}

public final class PKHUDProgressView: UIView, PKHUDAnimating {

    public init() {
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100)))
        commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit () {
        backgroundColor = UIColor.clear
        alpha = 0.8

        self.addSubview(activityIndicatorView)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = self.center
    }

    let activityIndicatorView: UIActivityIndicatorView = {
        #if swift(>=4.2)
        let activity = UIActivityIndicatorView(style: .whiteLarge)
        #else
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        #endif
        activity.color = UIColor.black
        return activity
    }()

    public func startAnimation() {
        activityIndicatorView.startAnimating()
    }
    
    public func stopAnimation() {
//        activityIndicatorView.stopAnimating()
    }
}
