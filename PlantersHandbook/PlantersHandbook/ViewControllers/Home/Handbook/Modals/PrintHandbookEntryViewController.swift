//
//  PrintHandbookEntryViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-19.
//

import UIKit
import WebKit

class PrintHandbookEntryViewController: PrintHandbookEntryView, WKNavigationDelegate {
    
    var views : [UIView] = []
    var caches : [[[Cache]]] = []
    var amountOfBlocks = 0
    var amountOfSubBlocks = 0
    var amountOfCaches = 0
    var totalCash = 0
    var totalTrees = 0
    var totalDensity = 0
    let handbookEntry : HandbookEntry
    var noteSpace : CGFloat = 0;
    var extraCashLineSpace : CGFloat = 0;
    var generalInfoSpace : CGFloat = 0;
    var cacheSpace : CGFloat = 0;
    var seperatorSize : CGFloat = 5;
    var paddingForInsideText : CGFloat = 10;
    
    required init(handbookEntry: HandbookEntry) {
        self.handbookEntry = handbookEntry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func configureViews() {
        super.configureViews()
        collectInformation()
        createViews()
    }
    
    fileprivate func collectInformation(){
        noteSpace = view.safeAreaFrame.height*0.03*CGFloat(1 + handbookEntry.notes.count/18)
        extraCashLineSpace = view.safeAreaFrame.height*0.03
        generalInfoSpace = view.safeAreaFrame.height*0.15
        cacheSpace = view.safeAreaFrame.height*0.19*0.31*29
    }
    
    fileprivate func createViews(){
        
        let titleLayout = SUI_View(backgoundColor: .systemBackground)
        titleLayout.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        titleLayout.heightAnchor.constraint(equalToConstant: view.safeAreaFrame.height*0.07).isActive = true
        
        let dateTitle = SUI_Label(title: GeneralFunctions.getDate(from: handbookEntry.date), fontSize: FontSize.extraLarge)
        dateTitle.widthAnchor.constraint(equalToConstant: view.frame.width*0.5).isActive = true
        dateTitle.heightAnchor.constraint(equalToConstant: view.safeAreaFrame.height*0.07).isActive = true
        dateTitle.padding(padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        
        [dateTitle, pdfButton].forEach{titleLayout.addSubview($0)}
        
        dateTitle.anchorCenter(to: titleLayout)
        pdfButton.anchorCenterY(to: titleLayout)
        pdfButton.anchor(top: nil, leading: nil, bottom: nil, trailing: titleLayout.trailingAnchor)
        
        pdfButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        
        stackView.addArrangedSubview(titleLayout)
        
        let topLayoutHieght = view.frame.height*0.1
        print(topLayoutHieght)
        topLayout.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        topLayout.heightAnchor.constraint(equalToConstant: topLayoutHieght).isActive = true
        let totalCashLabel = SUI_Label(title: "Total Trees : ", fontSize: FontSize.medium)
        let totalTreesLabel = SUI_Label(title: "Total Cash : ", fontSize: FontSize.medium)
        let totalDensityLabel = SUI_Label(title: "Total Density : ", fontSize: FontSize.medium)
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
        
        let extraCashTitle = SUI_Label(title: " Extra Cash: ", fontSize: FontSize.medium)
        extraCashTitle.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        extraCashTitle.heightAnchor.constraint(equalToConstant: extraCashLineSpace).isActive = true
        extraCashTitle.textAlignment = .left
        extraCashTitle.padding(padding: .init(top: 0, left: 2, bottom: 0, right: 0))
        stackView.addArrangedSubview(extraCashTitle)
        
        for i in 0..<handbookEntry.extraCash.count{
            let extraCashLine = SUI_Label(title: "  Cash: " + handbookEntry.extraCash[i].cash.toCurrency() + " Reason: " + handbookEntry.extraCash[i].reason, fontSize: FontSize.small)
            extraCashLine.widthAnchor.constraint(equalToConstant: view.frame.width-paddingForInsideText).isActive = true
            extraCashLine.heightAnchor.constraint(equalToConstant: extraCashLineSpace).isActive = true
            stackView.addArrangedSubview(extraCashLine)
        }
        
        stackView.addArrangedSubview(addBar())

        //Notes
        let notesTitle = SUI_Label(title: " Notes: ", fontSize: FontSize.medium)
        notesTitle.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        notesTitle.heightAnchor.constraint(equalToConstant: extraCashLineSpace).isActive = true
        notesTitle.textAlignment = .left
        stackView.addArrangedSubview(notesTitle)

        let notes = SUI_TextView_MultiLine(text: handbookEntry.notes, fontSize: FontSize.small)
        notes.widthAnchor.constraint(equalToConstant: view.frame.width-paddingForInsideText).isActive = true
//        notes.heightAnchor.constraint(equalToConstant: (handbookEntry.notes != "" ? noteSpace : 0)).isActive = true
        if(handbookEntry.notes == ""){
            notes.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }else{
            adjustUITextViewHeight(arg: notes)
        }
        notes.textAlignment = .left
        stackView.addArrangedSubview(notes)

        //Gather all blocks of handbookNetry
        print(handbookEntry.blocks)
        let blocks = realmDatabase.getBlockRealm(predicate: NSPredicate(format: "_id IN %@", handbookEntry.blocks)).sorted(byKeyPath: "_id")
        var blockIndex = 0
        for block in blocks{
            var blockTotalTrees = 0
            var blockTotalCash = 0.0
            var blockTotalDensity = 0.0
            var totalPlotsBlock = 0.0
            var totalPlotsValueBlock = 0.0
            let subBlocks = realmDatabase.getSubBlockRealm(predicate: NSPredicate(format: "_id IN %@", block.subBlocks)).sorted(byKeyPath: "_id")
            var subBlockIndex = 0
            var blockLevelCacheArray : [[Cache]] = []
            for subBlock in subBlocks{
                var subBlockTotalTrees = 0
                var subBlockTotalCash = 0.0
                var subBlockTotalDensity = 0.0
                var totalPlotsSubBlock = 0.0
                var totalPlotsValueSubBlock = 0.0
                let caches = realmDatabase.getCacheRealm(predicate: NSPredicate(format: "_id IN %@", subBlock.caches)).sorted(byKeyPath: "_id")
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
        
        let scrollView = SUI_ScrollView()
        
        backgroundView.addSubview(scrollView)
        scrollView.anchor(top: backgroundView.topAnchor, leading: backgroundView.leadingAnchor, bottom: backgroundView.bottomAnchor, trailing: backgroundView.trailingAnchor)
        
        scrollView.addSubview(stackView)
        
        stackView.fillSuperView()
        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
    }
    
    fileprivate func addBar() -> UIView{
        let bar = SUI_View_UnderlineBar(color: .systemOrange)
        bar.widthAnchor.constraint(equalToConstant: view.frame.width-5).isActive = true
        bar.heightAnchor.constraint(equalToConstant:  seperatorSize).isActive = true
        return bar
    }
    
    // Export pdf from Save pdf in drectory and return pdf file path
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

    // Save pdf file in document directory
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
    
    fileprivate func addInfoView(title: String, totalTrees: Int, totalCash: Double, totalDensity: Double, backgroundColor: UIColor) -> UIView{
        
        let infoView = SUI_View(backgoundColor: backgroundColor)
        
        infoView.anchorHeightAndWidthConstants(width: view.frame.width-paddingForInsideText, height: generalInfoSpace)
        
        let titleLabel = SUI_Label(title: title, fontSize: FontSize.medium)
        let totalTreesLabel = SUI_Label(title: "Total Trees: " + String(totalTrees), fontSize: FontSize.small)
        let totalCashLabel = SUI_Label(title: "Total Cash: " + totalCash.toCurrency(), fontSize: FontSize.small)
        let totalDensityLabel = SUI_Label(title: "Total Density: " + String(totalDensity.round(to: 2)), fontSize: FontSize.small)

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
    
    fileprivate func addCacheView(cache: Cache, tag: (blockIndex: Int, subBlockIndex: Int, cacheIndex: Int)) -> UIView{
                
        let cacheView = SUI_View(backgoundColor: .gray)
        
        cacheView.anchorHeightAndWidthConstants(width: view.frame.width, height: cacheSpace)
        
        let cacheCollectionView = PH_CollectionView_PrintableCache()
        
        [cacheCollectionView].forEach{cacheView.addSubview($0)}
        cacheCollectionView.anchor(top: cacheView.topAnchor, leading: cacheView.leadingAnchor, bottom: cacheView.bottomAnchor, trailing: cacheView.trailingAnchor)
        
        cacheCollectionView.delegate = self
        cacheCollectionView.dataSource = self
        cacheCollectionView.tag = Int(String(1) + String(tag.blockIndex) + String(1) + String(tag.subBlockIndex) + String(1) + String(tag.cacheIndex))!
        cacheCollectionView.backgroundColor = .systemBackground
        
        return cacheView
    }
    
    @objc func share(_ sender: UIBarButtonItem) {
        pdfButton.isHidden = true
        let url = NSURL.fileURL(withPath: exportAsPdfFromView(fileName: "Tally Sheet : " + GeneralFunctions.getDate(from: handbookEntry.date)))
        pdfButton.isHidden = false
      let activity = UIActivityViewController(
        activityItems: [url],
        applicationActivities: nil
      )
      activity.popoverPresentationController?.barButtonItem = sender
      present(activity, animated: true, completion: nil)
    }
    
    func adjustUITextViewHeight(arg : UITextView){
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    
}

extension PrintHandbookEntryViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 11
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let blockIndex = Int(String(collectionView.tag).prefix(2).suffix(1))!
        let subBlockIndex = Int(String(collectionView.tag).prefix(4).suffix(1))!
        let cacheIndex = Int(String(collectionView.tag).prefix(6).suffix(1))!
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrintedTallyCell", for: indexPath) as! PrintedTallyCell
        cell.bottomBar.backgroundColor = .clear
        
        if(indexPath.row < 3 || indexPath.row > 22){
            cell.backgroundColor = .systemFill
        }
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
            }
            else if(indexPath.row == 23){
                cell.input.text = " TTrees"
            }
            else{
                cell.input.text = " TCash"
            }
            cell.backgroundColor = .secondarySystemFill
            return cell
        }
        //Check if its a plot
        else if(indexPath.section == 1 || indexPath.section == 2){
            if(indexPath.row > 2 && indexPath.row < 23){
                let plotInput = caches[blockIndex][subBlockIndex][cacheIndex].plots[indexPath.row-3]
                cell.input.text = (indexPath.section == 1 ? String(plotInput.inputOne) : String(plotInput.inputTwo))
                cell.backgroundColor = .systemOrange
            }
            else{
                cell.input.text = ""
                cell.backgroundColor = .secondarySystemFill
            }
            if cell.input.text == "0"{
                cell.input.text = ""
            }
            return cell
        }
        //Else its a bag up entry
        else{
            cell.backgroundColor = .systemBackground
            if(indexPath.row == 0){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].treeTypes[indexPath.section-3])
                cell.backgroundColor = .secondarySystemFill
            }
            else if(indexPath.row == 1){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].centPerTreeTypes[indexPath.section-3].toCurrency())
                cell.backgroundColor = .secondarySystemFill
            }
            else if(indexPath.row == 2){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].bundlesPerTreeTypes[indexPath.section-3])
                cell.backgroundColor = .secondarySystemFill
            }
            else if(indexPath.row < 23 && indexPath.row > 2){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].bagUpsPerTreeTypes[indexPath.row-3].input[indexPath.section-3])
            }
            else if(indexPath.row == 23){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].totalTreesPerTreeTypes[indexPath.section-3])
                cell.backgroundColor = .secondarySystemFill
            }
            else if(indexPath.row == 24){
                cell.input.text = String(caches[blockIndex][subBlockIndex][cacheIndex].totalCashPerTreeTypes[indexPath.section-3].toCurrency())
                cell.backgroundColor = .secondarySystemFill
            }
            if cell.input.text == "0" || cell.input.text == "$0.00" {
                cell.input.text = ""
            }
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/20, height: collectionView.frame.height)
    }

}
