//
//  LogoAnimationView.swift
//  PlantersHandbook
//
//  Created by Amer Hukic on 13/09/2018.
//  Copyright © 2018 Amer Hukic. All rights reserved.
//  Link: https://github.com/amerhukic/AnimatedGifLaunchScreen-Example/blob/master/AnimatedGifLaunchScreen-Example/LogoAnimationView.swift
//

import UIKit
import SwiftyGif

class LogoAnimationView: UIView {
    
    let logoGifImageView: UIImageView = {
        guard let gifImage = try? UIImage(gifName: "logoVideo.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: 1)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.init(red: 78/255, green: 215/255, blue: 140/255, alpha: 1)
        addSubview(logoGifImageView)
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoGifImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        logoGifImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height*0.3).isActive = true
    }
}
