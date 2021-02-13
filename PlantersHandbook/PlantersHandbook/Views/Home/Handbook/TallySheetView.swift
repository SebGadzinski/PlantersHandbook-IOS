//
//  TallySheetView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

class TallySheetView: ProgramicVC {

    internal var topLayout = SUI_View(backgoundColor: .systemBackground)
    internal var infoLayout = SUI_View(backgoundColor: .systemBackground)
    internal var bagUpsLayout = SUI_View(backgoundColor: .systemBackground)
    internal var totalsLayout = SUI_View(backgoundColor: .systemBackground)
    
    internal let dateLabel = SUI_Label(title: "", fontSize: FontSize.medium)
    internal let gpsButton = PH_Button_Tally(title: "GPS", fontSize: FontSize.extraSmall, borderColor: UIColor.green.cgColor)
    internal let plotsButton = PH_Button_Tally(title: "Plots", fontSize: FontSize.extraSmall, borderColor: UIColor.orange.cgColor)
    internal let clearButton = PH_Button_Tally(title: "Clear", fontSize: FontSize.extraSmall, borderColor: UIColor.red.cgColor)
    internal let treeTypesCollectionView = PH_CollectionView_Tally()
    internal let centPerTreeTypeCollectionView = PH_CollectionView_Tally()
    internal let bundlePerTreeTypeCollectionView = PH_CollectionView_Tally()
    internal var infoScrollView = SUI_ScrollView()
    internal var bagUpCollectionViews : [UICollectionView] = []
    internal var bagUpsScrollView = SUI_ScrollView()
    internal let totalCashPerTreeTypesCollectionView = PH_CollectionView_Tally()
    internal let totalTreesPerTreeTypesCollectionView = PH_CollectionView_Tally()
    internal var totalsScrollView = SUI_ScrollView()
    internal var widthOfCollectionCell: CGFloat!
    internal var heightOfCollectionCell: CGFloat!
    internal var widthOfCollectionLabel: CGFloat!
    
    internal override func configureViews() {
        super.configureViews()
        setUpTopLayout()
        setUpInfoLayout()
        setUpBagUpsLayout()
        setUpTotalsLayout()
    }
    
    internal override func setUpOverlay() {
        super.setUpOverlay()
        let frame = backgroundView.safeAreaFrame
        
        let blackBarTopLayout = UIView()
        blackBarTopLayout.backgroundColor = .secondaryLabel
        let blackBarBagUpLayout = UIView()
        blackBarBagUpLayout.backgroundColor = .secondaryLabel
        let blackBarTotalLayout = UIView()
        blackBarTotalLayout.backgroundColor = .secondaryLabel
        
        [topLayout, blackBarTopLayout, infoLayout, blackBarBagUpLayout, bagUpsLayout, blackBarTotalLayout, totalsLayout].forEach{backgroundView.addSubview($0)}

        topLayout.anchor(top: backgroundView.topAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor,size: .init(width: 0, height: frame.height*0.07))
        blackBarTopLayout.anchor(top: topLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: 3))
        infoLayout.anchor(top: blackBarTopLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.19))
        blackBarBagUpLayout.anchor(top: infoLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: 3))
        bagUpsLayout.anchor(top: blackBarBagUpLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.41))
        blackBarTotalLayout.anchor(top: bagUpsLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: 3))
        totalsLayout.anchor(top: blackBarTotalLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: backgroundView.bottomAnchor, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: 0))
        
        heightOfCollectionCell = infoLayout.safeAreaFrame.height * 0.31
    }
    
    private func setUpTopLayout(){
        let topFrame = topLayout.safeAreaFrame

        [dateLabel, gpsButton, plotsButton, clearButton].forEach{topLayout.addSubview($0)}

        dateLabel.anchor(top: topLayout.topAnchor, leading: topLayout.leadingAnchor, bottom: topLayout.bottomAnchor, trailing: nil, padding: .init(top: topLayout.center.y, left: 5, bottom: 0, right: 0), size: .init(width: topFrame.width*0.4, height: 0))

        clearButton.anchor(top: topLayout.topAnchor, leading: nil, bottom: topLayout.bottomAnchor, trailing: topLayout.trailingAnchor, padding: .init(top: topFrame.height/6, left: 0, bottom: topFrame.height/6, right: 10), size: .init(width: topFrame.width*0.15, height: 0))
        clearButton.layer.borderColor = UIColor.systemRed.cgColor

        plotsButton.anchor(top: topLayout.topAnchor, leading: nil, bottom: topLayout.bottomAnchor, trailing: clearButton.leadingAnchor, padding: .init(top: topFrame.height/6, left: 0, bottom: topFrame.height/6, right: 10), size: .init(width: topFrame.width*0.15, height: 0))
        plotsButton.layer.borderColor = UIColor.systemOrange.cgColor

        gpsButton.anchor(top: topLayout.topAnchor, leading: nil, bottom: topLayout.bottomAnchor, trailing: plotsButton.leadingAnchor, padding: .init(top: topFrame.height/6, left: 0, bottom: topFrame.height/6, right: 10), size: .init(width: topFrame.width*0.2, height: 0))
        gpsButton.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    private func setUpInfoLayout(){
        let treeTypeImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-tree-64-white.png" : "icons8-tree-64.png")
        let cenPerTreeImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-cent-50-white.png" : "icons8-cent-100.png")
        let bundleImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-hay-52-white.png" : "icons8-hay-26.png")

        let treeTypesImg = UIImageView(image: UIImage(named: treeTypeImgString)!)
        let centPerTreeImg = UIImageView(image: UIImage(named: cenPerTreeImgString)!)
        let bundleImg = UIImageView(image: UIImage(named: bundleImgString)!)
        
        [treeTypesImg, centPerTreeImg, bundleImg, infoScrollView].forEach{infoLayout.addSubview($0)}
        
        widthOfCollectionLabel = infoLayout.safeAreaFrame.width*0.1
        
        treeTypesImg.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 5, bottom: 0, right: 0), size: .init(width: widthOfCollectionLabel, height: heightOfCollectionCell))

        centPerTreeImg.anchor(top: treeTypesImg.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 5, bottom: 0, right: 0))
        centPerTreeImg.anchorSize(to: treeTypesImg)

        bundleImg.anchor(top: centPerTreeImg.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 5, bottom: 0, right: 0))
        bundleImg.anchorSize(to: treeTypesImg)

        infoScrollView.frame = .init(x: 0, y: 0, width: infoLayout.safeAreaFrame.width - treeTypesImg.frame.width, height: infoLayout.safeAreaFrame.height)
        infoScrollView.translatesAutoresizingMaskIntoConstraints = false
        infoScrollView.isScrollEnabled = true
        infoScrollView.showsHorizontalScrollIndicator = false
        infoScrollView.backgroundColor = .systemBackground
        infoScrollView.anchor(top: infoLayout.topAnchor, leading: treeTypesImg.trailingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor)
        
        widthOfCollectionCell = infoScrollView.safeAreaFrame.width * 0.20
        
        [treeTypesCollectionView, centPerTreeTypeCollectionView, bundlePerTreeTypeCollectionView].forEach{infoScrollView.addSubview($0)}

        treeTypesCollectionView.anchor(top: infoScrollView.topAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*9, height: heightOfCollectionCell))

        centPerTreeTypeCollectionView.anchor(top: treeTypesCollectionView.bottomAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0))
        centPerTreeTypeCollectionView.anchorSize(to: treeTypesCollectionView)

        bundlePerTreeTypeCollectionView.anchor(top: centPerTreeTypeCollectionView.bottomAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0))
        bundlePerTreeTypeCollectionView.anchorSize(to: treeTypesCollectionView)

        infoScrollView.contentSize = .init(width: widthOfCollectionCell*9, height: infoLayout.safeAreaFrame.height)
    }
    
    private func setUpBagUpsLayout(){
        bagUpsLayout.addSubview(bagUpsScrollView)
        
        bagUpsScrollView.frame = .init(x: 0, y: 0, width: bagUpsLayout.safeAreaFrame.width, height: bagUpsLayout.safeAreaFrame.height)
        bagUpsScrollView.anchor(top: bagUpsLayout.topAnchor, leading: bagUpsLayout.leadingAnchor, bottom: bagUpsLayout.bottomAnchor, trailing: bagUpsLayout.trailingAnchor)
        bagUpsScrollView.translatesAutoresizingMaskIntoConstraints = false
        bagUpsScrollView.isScrollEnabled = true
        bagUpsScrollView.showsHorizontalScrollIndicator = false
        bagUpsScrollView.showsVerticalScrollIndicator = true
        bagUpsScrollView.backgroundColor = .systemBackground
        bagUpsScrollView.isDirectionalLockEnabled = true
        
        var labels : [UILabel] = []
        
        for i in 0..<20 {
            let label = UILabel()
            label.text = String(i+1)
            label.textAlignment = .center
            label.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.large))
            labels.append(label)
            bagUpCollectionViews.append(PH_CollectionView_Tally())
            bagUpCollectionViews[i].tag = i
        }
        
        labels.forEach{bagUpsScrollView.addSubview($0)}
        bagUpCollectionViews.forEach{bagUpsScrollView.addSubview($0)}
        
        labels[0].anchor(top: bagUpsScrollView.topAnchor, leading: bagUpsScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: widthOfCollectionLabel+5, height: heightOfCollectionCell*0.90)) // + 5 for margins on  a imageview
        
        bagUpCollectionViews[0].anchor(top: bagUpsScrollView.topAnchor, leading: labels[0].trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*9.5, height: heightOfCollectionCell*0.90))
        
        labels[0].anchorCenterY(to: bagUpCollectionViews[0])
        
        for i in 1..<labels.count {
            bagUpCollectionViews[i].anchor(top: bagUpCollectionViews[i-1].bottomAnchor, leading: bagUpCollectionViews[i-1].leadingAnchor, bottom: nil, trailing: nil)
            bagUpCollectionViews[i].anchorSize(to: bagUpCollectionViews[i-1])
    
            labels[i].anchor(top: nil, leading: bagUpsScrollView.leadingAnchor, bottom: nil, trailing: nil)
            labels[i].anchorSize(to: labels[i-1])
            labels[i].anchorCenterY(to: bagUpCollectionViews[i])
        }
        
        bagUpsScrollView.contentSize = .init(width: widthOfCollectionCell*9.6, height: heightOfCollectionCell*27) //Seems as margins increased the height
    }
    
    private func setUpTotalsLayout(){
        let totalTreeImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-floating-island-forest-64-white.png" : "icons8-floating-island-forest-64.png")
        let totalCashImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-cash-app-50-white.png" : "icons8-cash-app-100.png")
        
        let totalTreeImg = UIImageView(image: UIImage(named: totalTreeImgString)!)
        let totalCashImg = UIImageView(image: UIImage(named: totalCashImgString)!)
        
        let totalsFrame = totalsLayout.safeAreaFrame
        
        [totalTreeImg, totalCashImg, totalsScrollView].forEach{totalsLayout.addSubview($0)}
                
        totalTreeImg.anchor(top: totalsLayout.topAnchor, leading: totalsLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 5, bottom: 0, right: 0), size: .init(width: widthOfCollectionLabel, height: heightOfCollectionCell))

        totalCashImg.anchor(top: totalTreeImg.bottomAnchor, leading: totalsLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 5, bottom: 0, right: 0))
        totalCashImg.anchorSize(to: totalTreeImg)

        totalsScrollView.frame = .init(x: 0, y: 0, width: totalsFrame.width - totalTreeImg.frame.width, height: totalsFrame.height)
        totalsScrollView.translatesAutoresizingMaskIntoConstraints = false
        totalsScrollView.isScrollEnabled = true
        totalsScrollView.isDirectionalLockEnabled = true
        totalsScrollView.showsHorizontalScrollIndicator = false
        totalsScrollView.showsVerticalScrollIndicator = false
        totalsScrollView.backgroundColor = .systemBackground
        totalsScrollView.anchor(top: totalsLayout.topAnchor, leading: totalTreeImg.trailingAnchor, bottom: totalsLayout.bottomAnchor, trailing: totalsLayout.trailingAnchor)
        
        [totalCashPerTreeTypesCollectionView, totalTreesPerTreeTypesCollectionView,].forEach{totalsScrollView.addSubview($0)}

        totalTreesPerTreeTypesCollectionView.anchor(top: totalsScrollView.topAnchor, leading: totalsScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*9, height: heightOfCollectionCell))

        totalCashPerTreeTypesCollectionView.anchor(top: totalTreesPerTreeTypesCollectionView.bottomAnchor, leading: totalTreesPerTreeTypesCollectionView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 0, bottom: 0, right: 0))
        totalCashPerTreeTypesCollectionView.anchorSize(to: totalTreesPerTreeTypesCollectionView)

        totalsScrollView.contentSize = .init(width: widthOfCollectionCell*9, height: totalTreesPerTreeTypesCollectionView.frame.height + totalCashPerTreeTypesCollectionView.frame.height)
    }
    
}