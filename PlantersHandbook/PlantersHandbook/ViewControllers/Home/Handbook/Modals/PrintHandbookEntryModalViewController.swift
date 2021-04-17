//
//  PrintHandbookEntryViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-19.
//

import UIKit
import WebKit

///PrintHandbookEntryModalViewController.swift - Prints out all information of a handbookEntry
class PrintHandbookEntryModalViewController: PrintHandbookEntryModalView, WKNavigationDelegate {
    var views : [UIView] = []
    var caches : [[[Cache]]] = []
    var totalCash = 0
    var totalTrees = 0
    var totalDensity = 0
    let handbookEntry : HandbookEntry
    var extraCashLineSpace : CGFloat = 0;
    var generalInfoSpace : CGFloat = 0;
    var seperatorSize : CGFloat = 5;
    var paddingForInsideText : CGFloat = 10;
    
    ///Contructor that initalizes required fields
    ///- Parameter handbookEntry: HandbookEntry to be printed
    required init(handbookEntry: HandbookEntry) {
        self.handbookEntry = handbookEntry
        super.init(nibName: nil, bundle: nil)
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        setUpSizes()
        fillStackView()
    }
    
    ///Sets up the sizes of all abstract layouts in printed HandbookEntry
    fileprivate func setUpSizes(){
        extraCashLineSpace = view.safeAreaFrame.height*0.03
        generalInfoSpace = view.safeAreaFrame.height*0.15
    }
    
    ///Fills the stack view by dynamically adding views needed
    fileprivate func fillStackView(){
        let titleLayout = SUI.view(backgoundColor: .systemBackground)
        titleLayout.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        titleLayout.heightAnchor.constraint(equalToConstant: view.safeAreaFrame.height*0.07).isActive = true
        
        let dateTitle = SUI.label(title: GeneralFunctions.getDate(from: handbookEntry.date), fontSize: FontSize.extraLarge)
        dateTitle.widthAnchor.constraint(equalToConstant: view.frame.width*0.4).isActive = true
        dateTitle.heightAnchor.constraint(equalToConstant: view.safeAreaFrame.height*0.07).isActive = true
        dateTitle.padding(padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        
        let nameLabel = SUI.label(title: "", fontSize: FontSize.extraLarge)
        if let user = realmDatabase.findLocalUser(){
            nameLabel.text = user.name
        }
        
        [nameLabel, dateTitle, shareButton].forEach{titleLayout.addSubview($0)}
        
        nameLabel.anchor(top: nil, leading: titleLayout.leadingAnchor, bottom: nil, trailing: dateTitle.leadingAnchor, padding: .init(top: 0, left: 5, bottom: 0, right: 15))
        nameLabel.anchorCenterY(to: titleLayout)
        dateTitle.anchorCenter(to: titleLayout)
        dateTitle.translatesAutoresizingMaskIntoConstraints = false
        dateTitle.adjustsFontSizeToFitWidth = true
        dateTitle.sizeToFit()
        shareButton.anchorCenterY(to: titleLayout)
        shareButton.anchor(top: nil, leading: nil, bottom: nil, trailing: titleLayout.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 5))
        
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        
        stackView.addArrangedSubview(titleLayout)
        
        let topLayoutHieght = view.frame.height*0.1
        print(topLayoutHieght)
        let topLayout = SUI.view(backgoundColor: .systemBackground)
        topLayout.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        topLayout.heightAnchor.constraint(equalToConstant: topLayoutHieght).isActive = true
        let totalCashLabel = SUI.label(title: "Total Trees : ", fontSize: FontSize.medium)
        let totalTreesLabel = SUI.label(title: "Total Cash : ", fontSize: FontSize.medium)
        let totalDensityLabel = SUI.label(title: "Total Density : ", fontSize: FontSize.medium)
        var totalTrees = 0
        var totalCash : Double = 0.0
        var totalPlots : Double = 0.0
        var totalPlotsValue : Double = 0.0
        
        [totalCashLabel, totalTreesLabel, totalDensityLabel].forEach{topLayout.addSubview($0)}
        
        totalCashLabel.anchor(top: topLayout.topAnchor, leading: topLayout.leadingAnchor, bottom: nil, trailing: topLayout.trailingAnchor)
        totalCashLabel.heightAnchor.constraint(equalToConstant: topLayoutHieght*0.33).isActive = true
        
        totalTreesLabel.anchor(top: totalCashLabel.bottomAnchor, leading: topLayout.leadingAnchor, bottom: nil, trailing: topLayout.trailingAnchor)
        totalTreesLabel.heightAnchor.constraint(equalToConstant: topLayoutHieght*0.33).isActive = true
        
        totalDensityLabel.anchor(top: totalTreesLabel.bottomAnchor, leading: topLayout.leadingAnchor, bottom: nil, trailing: topLayout.trailingAnchor)
        totalDensityLabel.heightAnchor.constraint(equalToConstant: topLayoutHieght*0.33).isActive = true
        
        stackView.addArrangedSubview(topLayout)
        stackView.addArrangedSubview(addBar())
        
        let extraCashTitle = SUI.label(title: " Extra Cash: ", fontSize: FontSize.medium)
        extraCashTitle.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        extraCashTitle.heightAnchor.constraint(equalToConstant: extraCashLineSpace).isActive = true
        extraCashTitle.textAlignment = .left
        extraCashTitle.padding(padding: .init(top: 0, left: 2, bottom: 0, right: 0))
        stackView.addArrangedSubview(extraCashTitle)
        
        for i in 0..<handbookEntry.extraCash.count{
            let extraCashLine = SUI.textViewMultiLine(text: "Cash: " + handbookEntry.extraCash[i].cash.toCurrency() + " Reason: " + handbookEntry.extraCash[i].reason, fontSize: FontSize.small)
            extraCashLine.widthAnchor.constraint(equalToConstant: view.frame.width-paddingForInsideText).isActive = true
            GeneralFunctions.adjustUITextViewHeight(arg: extraCashLine)
            stackView.addArrangedSubview(extraCashLine)
        }
        
        stackView.addArrangedSubview(addBar())

        //Notes
        let notesTitle = SUI.label(title: " Notes: ", fontSize: FontSize.medium)
        notesTitle.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        notesTitle.heightAnchor.constraint(equalToConstant: extraCashLineSpace).isActive = true
        notesTitle.textAlignment = .left
        stackView.addArrangedSubview(notesTitle)

        let notes = SUI.textViewMultiLine(text: handbookEntry.notes, fontSize: FontSize.small)
        notes.widthAnchor.constraint(equalToConstant: view.frame.width-paddingForInsideText).isActive = true
        if(handbookEntry.notes == ""){
            notes.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }else{
            GeneralFunctions.adjustUITextViewHeight(arg: notes)
        }
        notes.textAlignment = .left
        notes.isEditable = false
        stackView.addArrangedSubview(notes)

        //Gather all blocks of handbookNetry
        print(handbookEntry.blocks)
        let blocks = realmDatabase.findObjectRealm(predicate: NSPredicate(format: "_id IN %@", handbookEntry.blocks), classType: Block()).sorted(byKeyPath: "_id")
        var blockIndex = 0
        for block in blocks{
            var blockTotalTrees = 0
            var blockTotalCash = 0.0
            var blockTotalDensity = 0.0
            var totalPlotsBlock = 0.0
            var totalPlotsValueBlock = 0.0
            let subBlocks = realmDatabase.findObjectRealm(predicate: NSPredicate(format: "_id IN %@", block.subBlocks), classType: SubBlock()).sorted(byKeyPath: "_id")
            var subBlockIndex = 0
            var blockLevelCacheArray : [[Cache]] = []
            for subBlock in subBlocks{
                var subBlockTotalTrees = 0
                var subBlockTotalCash = 0.0
                var subBlockTotalDensity = 0.0
                var totalPlotsSubBlock = 0.0
                var totalPlotsValueSubBlock = 0.0
                let caches = realmDatabase.findObjectRealm(predicate: NSPredicate(format: "_id IN %@", subBlock.caches), classType: Cache()).sorted(byKeyPath: "_id")
                var cacheIndex = 0
                var subBlockLevelCacheArray : [Cache] = []
                for cache in caches{
                    var cacheTotalTrees = 0
                    var cacheTotalCash = 0.0
                    var cacheTotalDensity : Double = 0

                    cache.totalCashPerTreeTypes.forEach{
                        cacheTotalCash += $0
                        subBlockTotalCash += $0
                        blockTotalCash += $0
                        totalCash += $0
                    }
                    cache.totalTreesPerTreeTypes.forEach{
                        cacheTotalTrees += $0
                        subBlockTotalTrees += $0
                        blockTotalTrees += $0
                        totalTrees += $0
                    }

                    cacheTotalDensity = GeneralFunctions.totalDensityFromArray(plotArray: cache.plots)

                    let plotsFromCache = GeneralFunctions.totalPlotsFromArray(plotArray: cache.plots)
                    totalPlotsSubBlock += plotsFromCache
                    totalPlotsBlock += plotsFromCache
                    totalPlots += plotsFromCache

                    let plotsValueFromCache = GeneralFunctions.totalPlotsValueFromArray(plotArray: cache.plots)
                    totalPlotsValueSubBlock += plotsValueFromCache
                    totalPlotsValueBlock += plotsValueFromCache
                    totalPlotsValue += plotsValueFromCache

                    views.append(addCacheView(cache: cache, tag: (blockIndex,subBlockIndex, cacheIndex)))
                    views.append(addBar())
                    views.append(addInfoView(title: ("Cache: " + cache.title), totalTrees: cacheTotalTrees, totalCash: cacheTotalCash, totalDensity: cacheTotalDensity, backgroundColor: .secondarySystemFill))
                    views.append(addBar())

                    subBlockLevelCacheArray.append(cache)
                    cacheIndex += 1
                }
                subBlockTotalDensity = GeneralFunctions.calculateDensity(plots: totalPlotsSubBlock, plotsValue: totalPlotsValueSubBlock)
                views.append(addInfoView(title: ("SubBlock: " + subBlock.title), totalTrees: subBlockTotalTrees, totalCash: subBlockTotalCash, totalDensity: subBlockTotalDensity, backgroundColor: .tertiarySystemFill))
                views.append(addBar())

                blockLevelCacheArray.append(subBlockLevelCacheArray)
                subBlockIndex += 1
            }
            blockTotalDensity = GeneralFunctions.calculateDensity(plots: totalPlotsBlock, plotsValue: totalPlotsValueBlock)
            views.append((addInfoView(title: ("Block: " + block.title), totalTrees: blockTotalTrees, totalCash: blockTotalCash, totalDensity: blockTotalDensity, backgroundColor: .quaternarySystemFill)))
            views.append(addBar())

            caches.append(blockLevelCacheArray)
            blockIndex += 1
        }
        
        totalCashLabel.text = totalCashLabel.text! + totalCash.toCurrency()
        totalTreesLabel.text = totalTreesLabel.text! + String(totalTrees)
        totalDensityLabel.text = totalDensityLabel.text! + String(GeneralFunctions.calculateDensity(plots: totalPlots, plotsValue: totalPlotsValue).round(to: 2))
        
        views.reverse()
        for view in views{
            stackView.addArrangedSubview(view)
        }
        
        let scrollView = SUI.ScrollView()
        
        backgroundView.addSubview(scrollView)
        scrollView.anchor(top: backgroundView.topAnchor, leading: backgroundView.leadingAnchor, bottom: backgroundView.bottomAnchor, trailing: backgroundView.trailingAnchor)
        
        scrollView.addSubview(stackView)
        
        stackView.fillSuperView()
        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
    }
    
    ///Returns a thin bar meant to use as a seperator
    ///- Returns: Thin bar meant to use as a seperator
    fileprivate func addBar() -> UIView{
        let bar = SUI.underlineBar(color: .systemOrange)
        bar.widthAnchor.constraint(equalToConstant: view.frame.width-5).isActive = true
        bar.heightAnchor.constraint(equalToConstant:  seperatorSize).isActive = true
        return bar
    }
    
    ///Export pdf from Save pdf in drectory and return pdf file path
    ///- Returns: File path of pdf
    func exportAsPdfFromView(fileName: String) -> String {
        let pdfPageFrame = stackView.bounds
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return "" }
        
        stackView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        return self.saveViewPdf(data: pdfData, fileName: fileName)

    }

    ///Save pdf file in document directory
    ///- Returns: File location of pdf
    func saveViewPdf(data: NSMutableData, fileName: String) -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent(fileName + ".pdf")
        if data.write(to: pdfPath, atomically: true) {
          return pdfPath.path
        } else {
            return ""
        }
    }
    
    ///Creates a heading information view for a block, subBlock, or cache
    ///- Parameter title: Title of block, subBlock, or cache
    ///- Parameter totalTrees: Total amount of trees planted in block, subBlock, or cache
    ///- Parameter totalCash: Total amount of cash made in block, subBlock, or cache
    ///- Parameter totalDensity: Total density from trees planted in block, subBlock, or cache
    ///- Parameter backgroundColor: Background color of view
    fileprivate func addInfoView(title: String, totalTrees: Int, totalCash: Double, totalDensity: Double, backgroundColor: UIColor) -> UIView{
        
        let infoView = SUI.view(backgoundColor: backgroundColor)
        
        infoView.anchorHeightAndWidthConstants(width: view.frame.width-paddingForInsideText, height: generalInfoSpace)
        
        let titleLabel = SUI.label(title: title, fontSize: FontSize.medium)
        let totalTreesLabel = SUI.label(title: "Total Trees: " + String(totalTrees), fontSize: FontSize.small)
        let totalCashLabel = SUI.label(title: "Total Cash: " + totalCash.toCurrency(), fontSize: FontSize.small)
        let totalDensityLabel = SUI.label(title: "Total Density: " + String(totalDensity.round(to: 2)), fontSize: FontSize.small)

        [titleLabel, totalTreesLabel, totalCashLabel, totalDensityLabel].forEach{infoView.addSubview($0)}

        titleLabel.anchor(top: infoView.topAnchor, leading: infoView.leadingAnchor, bottom: nil, trailing: infoView.trailingAnchor)
        titleLabel.heightAnchor.constraint(equalToConstant: generalInfoSpace*0.35).isActive = true

        totalTreesLabel.anchor(top: titleLabel.bottomAnchor, leading: infoView.leadingAnchor, bottom: nil, trailing: infoView.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        totalTreesLabel.heightAnchor.constraint(equalToConstant: generalInfoSpace*0.2).isActive = true
        totalTreesLabel.textAlignment = .left

        totalCashLabel.anchor(top: totalTreesLabel.bottomAnchor, leading: infoView.leadingAnchor, bottom: nil, trailing: infoView.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        totalCashLabel.heightAnchor.constraint(equalToConstant: generalInfoSpace*0.2).isActive = true
        totalCashLabel.textAlignment = .left

        totalDensityLabel.anchor(top: totalCashLabel.bottomAnchor, leading: infoView.leadingAnchor, bottom: nil, trailing: infoView.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 0, right: 0))
        totalDensityLabel.heightAnchor.constraint(equalToConstant: generalInfoSpace*0.2).isActive = true
        totalDensityLabel.textAlignment = .left
        
        return infoView
    }
    
    ///Creates a cache view containing all inputs and totals
    ///- Parameter cache: Cache to be used for data extraction
    ///- Parameter tag: Location of cache in caches list
    fileprivate func addCacheView(cache: Cache, tag: (blockIndex: Int, subBlockIndex: Int, cacheIndex: Int)) -> UIView{
                
        let cacheView = SUI.view(backgoundColor: .systemBackground)
        
        cacheView.anchorHeightAndWidthConstants(width: view.frame.width, height: 40*27)
        
        let cacheCollectionView = PHUI.collectionViewPrintableCache()
        
        [cacheCollectionView].forEach{cacheView.addSubview($0)}
        cacheCollectionView.anchor(top: cacheView.topAnchor, leading: cacheView.leadingAnchor, bottom: cacheView.bottomAnchor, trailing: cacheView.trailingAnchor)
        
        cacheCollectionView.delegate = self
        cacheCollectionView.dataSource = self
        cacheCollectionView.tag = Int(String(1) + String(tag.blockIndex) + String(1) + String(tag.subBlockIndex) + String(1) + String(tag.cacheIndex))!
        cacheCollectionView.backgroundColor = .systemBackground
        
        return cacheView
    }
    
    ///Share the pdf view of the printed HandbookEntry
    ///- Parameter sender: Share button
    @objc func share(_ sender: UIBarButtonItem) {
        shareButton.isHidden = true
        let url = NSURL.fileURL(withPath: exportAsPdfFromView(fileName: "Tally Sheet : " + GeneralFunctions.getDate(from: handbookEntry.date)))
        shareButton.isHidden = false
      let activity = UIActivityViewController(
        activityItems: [url],
        applicationActivities: nil
      )
        activity.popoverPresentationController?.delegate = self
        activity.popoverPresentationController?.sourceView = shareButton
//        self.preferredContentSize = CGSize(width: view.frame.width, height: view.frame.height-100)
        activity.popoverPresentationController?.permittedArrowDirections = .any
      present(activity, animated: true, completion: nil)
    }
    
}

///Functionality required for using UICollectionViewDelegate, UICollectionViewDataSource
extension PrintHandbookEntryModalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    ///Asks your data source object for the number of items in the specified section.
    ///- Parameter collectionView: The collection view object displaying the flow layout.
    ///- Parameter numberOfItemsInSection: Given number of items to be insection
    ///- Returns: Number of items to be insection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    ///Asks your data source object for the number of sections in the collection view.
    ///- Parameter collectionView: The collection view requesting this information.
    ///- Returns: The number of sections in collectionView.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 11
    }

    ///Asks your data source object for the cell that corresponds to the specified item in the collection view.
    ///- Parameter collectionView: The collection view object displaying the flow layout.
    ///- Parameter indexPath: Index path that specifies location of item
    ///- Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let blockIndex = Int(String(collectionView.tag).prefix(2).suffix(1))!
        let subBlockIndex = Int(String(collectionView.tag).prefix(4).suffix(1))!
        let cacheIndex = Int(String(collectionView.tag).prefix(6).suffix(1))!
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrintedTallyCell", for: indexPath) as! PrintedTallyCell
        cell.bottomBar.backgroundColor = .clear

        //Check if its a number
        if(indexPath.section == 0){
            cell.input.textAlignment = .left
            if(indexPath.row == 0){
                cell.input.text = " Trees"
            }
            else if(indexPath.row == 1){
                cell.input.text = " Cents"
            }
            else if(indexPath.row == 2){
                cell.input.text = " Bundle"
            }
            else if(indexPath.row < 23 && indexPath.row > 2){
                cell.input.textAlignment = .center
                cell.input.text = String(indexPath.row-2)
                if indexPath.row % 2 == 0{
                    cell.input.backgroundColor = .lightGray
                }else{
                    cell.input.backgroundColor = (view.traitCollection.userInterfaceStyle == .dark ? .darkGray : .tertiarySystemFill)
                }
            }
            else if(indexPath.row == 23){
                cell.input.text = " TTrees"
            }
            else{
                cell.input.text = " TCash"
            }
            return cell
        }
        //Check if its a plot
        else if(indexPath.section == 1 || indexPath.section == 2){
            if(indexPath.row > 2 && indexPath.row < 23){
                let plotInput = caches[blockIndex][subBlockIndex][cacheIndex].plots[indexPath.row-3]
                cell.input.text = (indexPath.section == 1 ? String(plotInput.inputOne) : String(plotInput.inputTwo))
                cell.input.backgroundColor = .systemOrange
            }
            else{
                cell.input.text = ""
            }
            if cell.input.text == "0"{
                cell.input.text = ""
            }
            return cell
        }
        //Else its a bag up entry
        else{
            if(indexPath.row == 0){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].treeTypes[indexPath.section-3])
//                cell.backgroundColor = .secondarySystemFill
                cell.input.backgroundColor = .secondarySystemFill
            }
            else if(indexPath.row == 1){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].centPerTreeTypes[indexPath.section-3].toCurrency())
                cell.input.backgroundColor = .secondarySystemFill
            }
            else if(indexPath.row == 2){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].bundlesPerTreeTypes[indexPath.section-3])
                cell.input.backgroundColor = .secondarySystemFill
            }
            else if(indexPath.row < 23 && indexPath.row > 2){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].bagUpsPerTreeTypes[indexPath.row-3].input[indexPath.section-3])
                if indexPath.row % 2 == 0{
                    cell.input.backgroundColor = .lightGray
                }else{
                    cell.input.backgroundColor = (view.traitCollection.userInterfaceStyle == .dark ? .darkGray : .tertiarySystemFill)
                }
            }
            else if(indexPath.row == 23){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].totalTreesPerTreeTypes[indexPath.section-3])
                cell.input.backgroundColor = .secondarySystemFill
            }
            else if(indexPath.row == 24){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].totalCashPerTreeTypes[indexPath.section-3].toCurrency())
                cell.input.backgroundColor = .secondarySystemFill
            }
            if cell.input.text == "0" || cell.input.text == "$0.00" {
                cell.input.text = ""
            }
            cell.input.text = " " + cell.input.text! + " "
            cell.input.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraSmall))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }

    ///Asks the delegate for the size of the specified item’s cell
    ///- Parameter CollectionView: The collection view object displaying the flow layout.
    ///- Parameter collectionViewLayout: Layout object requesting information
    ///- Parameter sizeForItemAt: Size for the items at that indexPath
    ///- Parameter indexPath: Index path of item
    ///- Returns: The width and height of the specified item. Both values must be greater than 0.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width)/11, height: 40)
    }

}
