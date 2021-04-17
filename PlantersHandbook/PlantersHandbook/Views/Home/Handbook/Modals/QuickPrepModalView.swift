//
//  QuickInfoModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-16.
//

import UIKit

///QuickPrepModalView.swift - View for QuickPrepModalViewController
class QuickPrepModalView: GeneralView {
    internal let titleLabel = SUI.label(title: "Quick Fill", fontSize: FontSize.largeTitle)
    internal let treeTypesCollectionView = PHUI.collectionViewTally()
    internal let centPerTreeTypeCollectionView = PHUI.collectionViewTally()
    internal let bundlePerTreeTypeCollectionView = PHUI.collectionViewTally()
    internal var infoScrollView = SUI.ScrollView()
    internal let confirmButton = PHUI.button(title: "Confirm", fontSize: FontSize.large)
    internal var widthOfCollectionCell: CGFloat!
    internal var heightOfCollectionCell: CGFloat!
    internal var widthOfCollectionLabel: CGFloat!
    internal var widthOfCollectionMultiplier : CGFloat!

    ///Set up title layout within general view controller
    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        titleLayout.addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    ///Set up info layout within general view controller
    internal override func setUpInfoLayout(){
        super.setUpInfoLayout()
        let treeTypeImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-tree-64-white.png" : "icons8-tree-64.png")
        let cenPerTreeImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-cent-50-white.png" : "icons8-cent-100.png")
        let bundleImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-hay-52-white.png" : "icons8-hay-26.png")

        let treeTypesImg = UIImageView(image: UIImage(named: treeTypeImgString)!)
        let centPerTreeImg = UIImageView(image: UIImage(named: cenPerTreeImgString)!)
        let bundleImg = UIImageView(image: UIImage(named: bundleImgString)!)
        
        [treeTypesImg, centPerTreeImg, bundleImg, infoScrollView, confirmButton].forEach{infoLayout.addSubview($0)}
        
        widthOfCollectionLabel = infoLayout.safeAreaFrame.width*0.1
        heightOfCollectionCell = view.safeAreaFrame.height*0.19*0.31
        
        treeTypesImg.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 5, bottom: 0, right: 0), size: .init(width: widthOfCollectionLabel, height: heightOfCollectionCell))

        centPerTreeImg.anchor(top: treeTypesImg.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 5, bottom: 0, right: 0))
        centPerTreeImg.anchorSize(to: treeTypesImg)

        bundleImg.anchor(top: centPerTreeImg.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 5, bottom: 0, right: 0))
        bundleImg.anchorSize(to: treeTypesImg)

        infoScrollView.translatesAutoresizingMaskIntoConstraints = false
        infoScrollView.isScrollEnabled = true
        infoScrollView.showsHorizontalScrollIndicator = false
        infoScrollView.backgroundColor = .systemBackground
        infoScrollView.anchor(top: infoLayout.topAnchor, leading: treeTypesImg.trailingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, size: .init(width: 0, height: heightOfCollectionCell*3.1))
        print(infoScrollView.frame)
        widthOfCollectionCell = (infoLayout.safeAreaFrame.width - treeTypesImg.frame.width) * 0.20
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            widthOfCollectionMultiplier = 9.67
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            widthOfCollectionMultiplier = 8.5
        }
        
        [treeTypesCollectionView, centPerTreeTypeCollectionView, bundlePerTreeTypeCollectionView].forEach{infoScrollView.addSubview($0)}

        treeTypesCollectionView.anchor(top: infoScrollView.topAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*widthOfCollectionMultiplier, height: heightOfCollectionCell))

        centPerTreeTypeCollectionView.anchor(top: treeTypesCollectionView.bottomAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0))
        centPerTreeTypeCollectionView.anchorSize(to: treeTypesCollectionView)

        bundlePerTreeTypeCollectionView.anchor(top: centPerTreeTypeCollectionView.bottomAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0))
        bundlePerTreeTypeCollectionView.anchorSize(to: treeTypesCollectionView)
        


        infoScrollView.contentSize = .init(width: widthOfCollectionCell*widthOfCollectionMultiplier, height: heightOfCollectionCell*3)
        
        confirmButton.anchor(top: infoScrollView.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 50, left: 0, bottom: 0, right: 0),size: .init(width: infoLayout.safeAreaFrame.width*0.4, height: 0))
        confirmButton.anchorCenterX(to: infoLayout)
    }

}
