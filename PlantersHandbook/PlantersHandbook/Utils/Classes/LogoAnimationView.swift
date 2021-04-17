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

///LogoAnimationView.swift - Runs a logo animation
class LogoAnimationView: UIView {
    
    let logoGifImageView: UIImageView = {
        guard let gifImage = try? UIImage(gifName: "logoAnimation_white.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: 1)
    }()
    let fileName : String
    
    required init(frame: CGRect, fileName: String) {
        self.fileName = fileName
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Sets up the animation contraints and file
    private func commonInit() {
        let animationGif = try? UIImage(gifName: fileName)
        logoGifImageView.setGifImage(animationGif!)
        
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBackground : UIColor.init(red: 252/255, green: 252/255, blue: 255/255, alpha: 1)
        addSubview(logoGifImageView)
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoGifImageView.widthAnchor.constraint(equalToConstant: 350).isActive = true
        logoGifImageView.heightAnchor.constraint(equalToConstant: 350).isActive = true
    }
}
