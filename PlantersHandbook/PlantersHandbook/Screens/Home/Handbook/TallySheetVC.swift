//
//  TallySheetVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class TallySheetVC: ProgramicVC {
    
    fileprivate var topLayout : UIView!
    fileprivate var infoLayout : UIView!
    fileprivate var bagUpsLayout : UIView!
    fileprivate var totalsLayout : UIView!
    
    let cache: Cache
    let realm: Realm
    let partitionValue: String
    
    fileprivate let dateLb = label_normal(title: "", fontSize: FontSize.meduim)
    fileprivate let gpsButton = ph_button_tally(title: "GPS", fontSize: FontSize.extraSmall, borderColor: UIColor.green.cgColor)
    fileprivate let plotsButton = ph_button_tally(title: "Plots", fontSize: FontSize.extraSmall, borderColor: UIColor.orange.cgColor)
    fileprivate let clearButton = ph_button_tally(title: "Clear", fontSize: FontSize.extraSmall, borderColor: UIColor.red.cgColor)
    fileprivate let treeTypesCv = tallyCV()
    fileprivate let centPerTreeTypeCv = tallyCV()
    fileprivate let bundlePerTreeTypeCv = tallyCV()
    fileprivate var infoScrollView = scrollViewNormal()
    fileprivate var bagUpCVs : [UICollectionView] = []
    fileprivate var bagUpsScrollView = scrollViewNormal()
    fileprivate let totalCashPerTreeTypesCv = tallyCV()
    fileprivate let totalTreesPerTreeTypesCv = tallyCV()
    fileprivate var totalsScrollView = scrollViewNormal()
    
    fileprivate var clearingData : Bool = false
    fileprivate var widthOfCollectionCell: CGFloat!
    fileprivate var heightOfCollectionCell: CGFloat!
    fileprivate var widthOfCollectionLabel: CGFloat!
    
    required init(realm: Realm, cache: Cache) {
        guard let syncConfiguration = realm.configuration.syncConfiguration else {
            fatalError("Sync configuration not found! Realm not opened with sync?")
        }
        
        self.realm = realm
        self.partitionValue = syncConfiguration.partitionValue!.stringValue!
        self.cache = cache
       
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Cache: " + cache.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func generateLayout() {
        topLayout = generalLayout(backgoundColor: .systemBackground)
        infoLayout = generalLayout(backgoundColor: .systemBackground)
        bagUpsLayout = generalLayout(backgoundColor: .systemBackground)
        totalsLayout = generalLayout(backgoundColor: .systemBackground)
    }
    
    override func configureViews() {
        setUpOverlay()
        setUpTopLayout()
        setUpInfoLayout()
        setUpBagUpsLayout()
        setUpTotalsLayout()
        setUpTableDelegates()
        keyboardMoveUpWhenTextFieldTouched = 0
    }
    
    override func setActions() {
        clearButton.addTarget(self, action: #selector(clearFieldsBtn), for: .touchUpInside)
        gpsButton.addTarget(self, action: #selector(gpsButtonAction), for: .touchUpInside)
        plotsButton.addTarget(self, action: #selector(plotsButtonAction), for: .touchUpInside)
    }

    func setUpOverlay(){
        let frame = bgView.safeAreaFrame
        
        let blackBarTopLayout = UIView()
        blackBarTopLayout.backgroundColor = .secondaryLabel
        let blackBarBagUpLayout = UIView()
        blackBarBagUpLayout.backgroundColor = .secondaryLabel
        let blackBarTotalLayout = UIView()
        blackBarTotalLayout.backgroundColor = .secondaryLabel
        
        [topLayout, blackBarTopLayout, infoLayout, blackBarBagUpLayout, bagUpsLayout, blackBarTotalLayout, totalsLayout].forEach{bgView.addSubview($0)}

        topLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor,size: .init(width: 0, height: frame.height*0.07))
        blackBarTopLayout.anchor(top: topLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: 3))
        infoLayout.anchor(top: blackBarTopLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.19))
        blackBarBagUpLayout.anchor(top: infoLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: 3))
        bagUpsLayout.anchor(top: blackBarBagUpLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.41))
        blackBarTotalLayout.anchor(top: bagUpsLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: 3))
        totalsLayout.anchor(top: blackBarTotalLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: bgView.bottomAnchor, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: 0))
        
        heightOfCollectionCell = infoLayout.safeAreaFrame.height * 0.31
    }
    
    func setUpTopLayout(){
        
        let topFrame = topLayout.safeAreaFrame

        [dateLb, gpsButton, plotsButton, clearButton].forEach{topLayout.addSubview($0)}

        dateLb.anchor(top: topLayout.topAnchor, leading: topLayout.leadingAnchor, bottom: topLayout.bottomAnchor, trailing: nil, padding: .init(top: topLayout.center.y, left: 5, bottom: 0, right: 0), size: .init(width: topFrame.width*0.4, height: 0))
        findHandbookDate()

        clearButton.anchor(top: topLayout.topAnchor, leading: nil, bottom: topLayout.bottomAnchor, trailing: topLayout.trailingAnchor, padding: .init(top: topFrame.height/6, left: 0, bottom: topFrame.height/6, right: 10), size: .init(width: topFrame.width*0.15, height: 0))
        clearButton.layer.borderColor = UIColor.systemRed.cgColor

        plotsButton.anchor(top: topLayout.topAnchor, leading: nil, bottom: topLayout.bottomAnchor, trailing: clearButton.leadingAnchor, padding: .init(top: topFrame.height/6, left: 0, bottom: topFrame.height/6, right: 10), size: .init(width: topFrame.width*0.15, height: 0))
        plotsButton.layer.borderColor = UIColor.systemOrange.cgColor

        gpsButton.anchor(top: topLayout.topAnchor, leading: nil, bottom: topLayout.bottomAnchor, trailing: plotsButton.leadingAnchor, padding: .init(top: topFrame.height/6, left: 0, bottom: topFrame.height/6, right: 10), size: .init(width: topFrame.width*0.2, height: 0))
        gpsButton.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    func setUpInfoLayout(){
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
        
        
        [treeTypesCv, centPerTreeTypeCv, bundlePerTreeTypeCv].forEach{infoScrollView.addSubview($0)}

        treeTypesCv.anchor(top: infoScrollView.topAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*9, height: heightOfCollectionCell))

        centPerTreeTypeCv.anchor(top: treeTypesCv.bottomAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0))
        centPerTreeTypeCv.anchorSize(to: treeTypesCv)

        bundlePerTreeTypeCv.anchor(top: centPerTreeTypeCv.bottomAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0))
        bundlePerTreeTypeCv.anchorSize(to: treeTypesCv)

        infoScrollView.contentSize = .init(width: widthOfCollectionCell*9, height: infoLayout.safeAreaFrame.height)
    }
    
    func setUpBagUpsLayout(){
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
            bagUpCVs.append(tallyCV())
            bagUpCVs[i].tag = i
        }
        
        labels.forEach{bagUpsScrollView.addSubview($0)}
        bagUpCVs.forEach{bagUpsScrollView.addSubview($0)}
        
        labels[0].anchor(top: bagUpsScrollView.topAnchor, leading: bagUpsScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: widthOfCollectionLabel+5, height: heightOfCollectionCell*0.90)) // + 5 for margins on  a imageview
        
        bagUpCVs[0].anchor(top: bagUpsScrollView.topAnchor, leading: labels[0].trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*9.5, height: heightOfCollectionCell*0.90))
        
        labels[0].anchorCenterY(to: bagUpCVs[0])
        
        for i in 1..<labels.count {
            bagUpCVs[i].anchor(top: bagUpCVs[i-1].bottomAnchor, leading: bagUpCVs[i-1].leadingAnchor, bottom: nil, trailing: nil)
            bagUpCVs[i].anchorSize(to: bagUpCVs[i-1])
    
            labels[i].anchor(top: nil, leading: bagUpsScrollView.leadingAnchor, bottom: nil, trailing: nil)
            labels[i].anchorSize(to: labels[i-1])
            labels[i].anchorCenterY(to: bagUpCVs[i])
        }
        
        bagUpsScrollView.contentSize = .init(width: widthOfCollectionCell*9.6, height: heightOfCollectionCell*27) //Seems as margins increased the height
    }
    
    func setUpTotalsLayout(){
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
        
        [totalCashPerTreeTypesCv, totalTreesPerTreeTypesCv,].forEach{totalsScrollView.addSubview($0)}

        totalTreesPerTreeTypesCv.anchor(top: totalsScrollView.topAnchor, leading: totalsScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*9, height: heightOfCollectionCell))

        totalCashPerTreeTypesCv.anchor(top: totalTreesPerTreeTypesCv.bottomAnchor, leading: totalTreesPerTreeTypesCv.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 0, bottom: 0, right: 0))
        totalCashPerTreeTypesCv.anchorSize(to: totalTreesPerTreeTypesCv)

        totalsScrollView.contentSize = .init(width: widthOfCollectionCell*9, height: totalTreesPerTreeTypesCv.frame.height + totalCashPerTreeTypesCv.frame.height)
    }
    
    func setUpTableDelegates(){
        treeTypesCv.delegate = self
        treeTypesCv.dataSource = self
        centPerTreeTypeCv.delegate = self
        centPerTreeTypeCv.dataSource = self
        bundlePerTreeTypeCv.delegate = self
        bundlePerTreeTypeCv.dataSource = self
        for i in 0..<20{
            bagUpCVs[i].delegate = self
            bagUpCVs[i].dataSource = self
        }
        totalTreesPerTreeTypesCv.delegate = self
        totalTreesPerTreeTypesCv.dataSource = self
        totalCashPerTreeTypesCv.delegate = self
        totalCashPerTreeTypesCv.dataSource = self
    }
    
    func findHandbookDate(){
        let subBlocks = realm.objects(SubBlock.self).filter(NSPredicate(format: "_id = %@", cache.subBlockId))
        dateLb.text = getDate(from: subBlocks[0].date)
    }
    
    @objc func gpsButtonAction(){
        let gpsModal = GPSTreeTrackingModal(realm: realm, title: self.title! + " GPS Tree Tracking", cacheCoordinates: cache.coordinatesCovered)
        gpsModal.modalPresentationStyle = .popover
        present(gpsModal, animated: true)
    }
    
    @objc func plotsButtonAction(){
        let plotsModal = PlotsModal(realm: realm, title: self.title! + " Plots", plots: cache.plots)
        plotsModal.modalPresentationStyle = .popover
        present(plotsModal, animated: true)
    }
    
    @objc func plotsActionButton(){
        
    }
    
    @objc func treeTypesInputAction(sender: UITextField){
        try! self.realm.write{
            cache.treeTypes[sender.tag] = sender.text!
        }
    }
    
    @objc func centPerTreeInputAction(sender: UITextField){
        if(containsLetters(input: sender.text!)){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for cent per tree value", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            try! self.realm.write{
                cache.centPerTreeTypes[sender.tag] = sender.text!.doubleValue
            }
            calculateTotalInLane(lane: sender.tag)
        }
    }
    
    @objc func bundleAmountInputAction(sender: UITextField){
        if(containsLetters(input: sender.text!)){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for bundle amount", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            try! self.realm.write{
                cache.bundlesPerTreeTypes[sender.tag] = integer(from: sender)
            }
            if(cache.bundlesPerTreeTypes[sender.tag] == 0){
                sender.text = ""
            }
        }
    }
    
    @objc func bagUpInputAction(sender: UITextField){
        let cvTag = sender.superview!.superview!.superview!.tag
        let tfTag = sender.tag
        let value = integer(from: sender)
        if(value == cache.bagUpsPerTreeTypes[cvTag].input[tfTag]){
            return
        }
        
        if(cache.bundlesPerTreeTypes[tfTag] == 0 && !clearingData){
            let alert = UIAlertController(title: "Error: Bundle Amount Not Set", message: "Please set bundle amount before continuing", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else if(cache.bundlesPerTreeTypes[tfTag] == 0 && clearingData){
            //Clearing Data Do Nothing
        }
        else{
            //Check if divisible by bundle amount
            if((value % cache.bundlesPerTreeTypes[tfTag]) != 0){
                //Alert not divisible
                let alert = UIAlertController(title: "Error: Divisibilty", message: "The bundle amount is not divisible by your input, " + String(value) + "/" + String(cache.bundlesPerTreeTypes[tfTag]) + " = " + String(Double(value)/Double(cache.bundlesPerTreeTypes[tfTag])), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                self.present(alert, animated: true)
                sender.text = ""
            }
            else{
                try! self.realm.write{
                    cache.bagUpsPerTreeTypes[cvTag].input[tfTag] = value
                }
                calculateTotalInLane(lane: tfTag)
                if(cache.bagUpsPerTreeTypes[cvTag].input[tfTag] == 0){
                    sender.text = ""
                }
            }
        }
    }
    
    @objc func clearFieldsBtn(sender: UIButton){
        clearingData = true
        try! self.realm.write{
            emptyTallyStringList(list: cache.treeTypes)
            emptyTallyDoubleList(list: cache.centPerTreeTypes)
            emptyTallyIntList(list: cache.bundlesPerTreeTypes)
            emptyTallyDoubleList(list: cache.totalCashPerTreeTypes)
            emptyTallyIntList(list: cache.totalTreesPerTreeTypes)
            emptyTallyBagUps(list: cache.bagUpsPerTreeTypes)
            emptyTallyPlots(list: cache.plots)
        }

        treeTypesCv.reloadData()
        centPerTreeTypeCv.reloadData()
        bundlePerTreeTypeCv.reloadData()
        bagUpCVs.forEach{$0.reloadData()}
        totalCashPerTreeTypesCv.reloadData()
        totalTreesPerTreeTypesCv.reloadData()
        clearingData = false
    }
    
    func calculateTotalInLane(lane: Int){
        var totalTreesInBagUps : Int = 0
        for x in 0...19{
            totalTreesInBagUps += cache.bagUpsPerTreeTypes[x].input[lane]
        }
        try! self.realm.write{
            cache.totalTreesPerTreeTypes[lane] = totalTreesInBagUps
            cache.totalCashPerTreeTypes[lane] = (Double(totalTreesInBagUps)*cache.centPerTreeTypes[lane])
        }
        totalTreesPerTreeTypesCv.reloadData()
        totalCashPerTreeTypesCv.reloadData()
    }
}


extension TallySheetVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthOfCollectionCell, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TallyCell", for: indexPath) as! TallyCell
        
        if(collectionView == self.totalTreesPerTreeTypesCv){
            cell.input.tag = indexPath.row
            cell.input.isUserInteractionEnabled = false
            cell.input.text = (cache.totalTreesPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.totalTreesPerTreeTypes[indexPath.row]))
            return cell
        }
        else if(collectionView == self.totalCashPerTreeTypesCv){
            cell.input.tag = indexPath.row
            cell.input.isUserInteractionEnabled = false
            cell.input.text = (cache.totalCashPerTreeTypes[indexPath.row] == 0 ? "" : cache.totalCashPerTreeTypes[indexPath.row].toCurrency())
            return cell
        }
        else if(collectionView == self.treeTypesCv){
            createAdvancedTallyCell(cell: cell, toolBar: kb, tag: indexPath.row, keyboardType: .default)
//            cell.input.addTarget(self, action: #selector(scrollAction), for: .allEvents)
            cell.input.addTarget(self, action: #selector(treeTypesInputAction), for: .editingDidEnd)
            cell.input.text = cache.treeTypes[indexPath.row]
            return cell
        }
        else if(collectionView == self.centPerTreeTypeCv){
            createAdvancedTallyCell(cell: cell, toolBar: kb, tag: indexPath.row, keyboardType: .decimalPad)
//            cell.entry.addTarget(self, action: #selector(scrollAction), for: .allEvents)
            cell.input.addTarget(self, action: #selector(centPerTreeInputAction), for: .editingDidEnd)
            cell.input.text = (cache.centPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.centPerTreeTypes[indexPath.row]))
            return cell
        }
        else if(collectionView == self.bundlePerTreeTypeCv){
            createAdvancedTallyCell(cell: cell, toolBar: kb, tag: indexPath.row, keyboardType: .numberPad)
//            cell.entry.addTarget(self, action: #selector(scrollAction), for: .allEvents)
            cell.input.addTarget(self, action: #selector(bundleAmountInputAction), for: .editingDidEnd)
            cell.input.text = (cache.bundlesPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.bundlesPerTreeTypes[indexPath.row]))
            return cell
        }
        else{
            createAdvancedTallyCell(cell: cell, toolBar: kb, tag: indexPath.row, keyboardType: .numberPad)
//            cell.entry.addTarget(self, action: #selector(scrollAction), for: .allEvents)
            cell.input.addTarget(self, action: #selector(bagUpInputAction), for: .editingDidEnd)
            cell.input.text = (cache.bagUpsPerTreeTypes[collectionView.tag].input[indexPath.row] == 0 ? "" : String(cache.bagUpsPerTreeTypes[collectionView.tag].input[indexPath.row]))
            return cell
        }
    }
}

