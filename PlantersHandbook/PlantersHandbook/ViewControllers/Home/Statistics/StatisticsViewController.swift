//
//  StatisticsViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import CoreLocation
import GoogleMaps
import Charts
import SwiftyGif

///StatisticsViewController.swift - Contains most important statistics extracted from planting data
class StatisticsViewController: StatisticsView, IValueFormatter, SwiftyGifDelegate {
    
    fileprivate var seasons: Results<Season>
    fileprivate var longPressGesture = UILongPressGestureRecognizer()
    fileprivate var cardIndexs : [Int] = [0,1,2,3,4,5,6,7,8,9,10]
    fileprivate var graphSeasonsIndexs : [Int] = [0,0,0,0,0,0,0,0,0,0,0]
    fileprivate var lookingAtGraphWithIndex = 0
    fileprivate var seasonsStatistics : [SeasonStatistics] = []
    fileprivate var justInitalized = true
    fileprivate var hasDisplayed = false
    fileprivate let stepDistance : Int
    private let refreshControl = UIRefreshControl()
    
    ///Contructor that initalizes required fields and does any neccesary start functionality
    required init() {
        if let user = realmDatabase.findLocalUser(){
            stepDistance = user.stepDistance
        }else{
            print("Could Not Find User")
            //Setting average for human
            stepDistance = 40
        }
        seasons = realmDatabase.findObjectRealm(predicate: nil, classType: Season()).sorted(byKeyPath: "_id")
        super.init(nibName: nil, bundle: nil)
        cardIndexs = getOrderOfCards()
        graphSeasonsIndexs = getOrderOfGraphSeasons()
        justInitalized = true
        collectInformation()
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        firstTimerKey = "StatisticsViewController"
        if(isFirstTimer()){
            let alertController = UIAlertController(title: "Statistics", message: "Welcome to the Statistics section! \nThis is where you can...\n1. Move statistics you like above others (Press and hold, then move it up or down) \n2. Click the 3 bars on the top right of a statistic card to change the season for the statistic \n\n In order to view some of these statistic cards you must create a season and have some entrys inside of it. (Line charts require 5 days)", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                self.saveFirstTimer(finishedFirstTime: true)
            })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        //Needs to load all cards by scrolling down to the bottom and then back up
        if !hasDisplayed{
            let loadingView = LogoAnimationView(frame: .zero, fileName: (traitCollection.userInterfaceStyle == .dark ? "stats-anim-black.gif" : "stats-anim-white.gif"))
            self.backgroundView.isHidden = false
            view.addSubview(loadingView)
            loadingView.fillSuperView()
            loadingView.logoGifImageView.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.cardsCollectionView.scrollToItem(at: IndexPath(item: 10, section: 0), at: .bottom, animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.didPullToRefresh(Object())
                    //Does not scroll to the top right away because there are graphs that glitch halfway
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.cardsCollectionView.scrollToItem(at: IndexPath(item: 8, section: 0), at: .bottom, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.cardsCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
                            self.hasDisplayed = true
                            //To show the statistics part in the animation (:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                loadingView.removeFromSuperview()
                            }
                        }
                    }
                }
            }
        }
    }

    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        cardsCollectionView.delegate = self
        cardsCollectionView.dataSource = self
        cardsCollectionView.dragDelegate = self
        cardsCollectionView.dropDelegate = self
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        setUpRefreshControl()
    }
    
    ///Sets up pull down to refresh on collection view
    private func setUpRefreshControl(){
        cardsCollectionView.alwaysBounceVertical = true
        cardsCollectionView.refreshControl = refreshControl
    }
    
    ///Functionality when colleciton view is refreshing
    ///- Parameter sender: Colleciton view that was pulled down to refresh
    @objc fileprivate func didPullToRefresh(_ sender: Any) {
        collectInformation()
        cardsCollectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    ///Collects all information needed from every season
    fileprivate func collectInformation(){
        if justInitalized{
            justInitalized = false
        }
        else{
            seasons = realmDatabase.findObjectRealm(predicate: nil, classType: Season()).sorted(byKeyPath: "_id")
        }
        for i in 0..<graphSeasonsIndexs.count{
            if seasons.count == graphSeasonsIndexs[i]{
                graphSeasonsIndexs[i] = 0
            }
        }
        
        seasonsStatistics.removeAll()
        if seasons.isEmpty{
            cardsCollectionView.reloadData()
        }
        for season in seasons{
            var seasonStats = SeasonStatistics(seasonName: String(season.title))
            
            let handbookEntries = realmDatabase.findObjectRealm(predicate: .init(format: "seasonId = %@", season._id), classType: HandbookEntry()).sorted(byKeyPath: "date", ascending: false)
            for handbookEntry in handbookEntries{
                var handbookEntryStats = HandbookEntryStatistics(date: handbookEntry.date)
                
                for entry in handbookEntry.extraCash{
                    handbookEntryStats.totalCash += entry.cash
                }
                
                let blocks = realmDatabase.findObjectRealm(predicate: .init(format: "entryId = %@", handbookEntry._id), classType: Block())
                for block in blocks{
                    let subBlocks = realmDatabase.findObjectRealm(predicate: .init(format: "blockId = %@", block._id), classType: SubBlock())
                    for subBlock in subBlocks{
                        let caches = realmDatabase.findObjectRealm(predicate: .init(format: "subBlockId = %@", subBlock._id), classType: Cache())
                        for cache in caches{
                            var prevCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                            
                            cache.totalCashPerTreeTypes.forEach{
                                handbookEntryStats.totalCash += $0
        
                            }
                            cache.totalTreesPerTreeTypes.forEach{
                                handbookEntryStats.totalTrees += $0
                            }
                            
                            //Displaying Purposes
                            
                            cache.secondsPlanted.forEach{
                                handbookEntryStats.totalTimeSecondsPlanting += $0
                            }
                            
                            for cacheCoordinateInputs in cache.coordinatesCovered{
                                for coordinate in cacheCoordinateInputs.input{
                                    let currentCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                    if(prevCoordinate.longitude != 0.0){
                                        handbookEntryStats.totalDistanceTravelled += GMSGeometryDistance(prevCoordinate, currentCoordinate)
                                    }
                                    prevCoordinate = currentCoordinate
                                }
                            }
                            
                        }
                    }
                }
                if seasonStats.bestEntryStats != nil{
                    if handbookEntryStats.totalCash > seasonStats.bestEntryStats!.totalCash{
                        seasonStats.bestEntryStats = handbookEntryStats
                    }
                }
                else{
                    seasonStats.bestEntryStats = handbookEntryStats
                }
                seasonStats.totalCash += handbookEntryStats.totalCash
                seasonStats.totalTrees += handbookEntryStats.totalTrees
                seasonStats.totalDistanceTravelled += handbookEntryStats.totalDistanceTravelled
                seasonStats.totalTimeSecondsPlanting += handbookEntryStats.totalTimeSecondsPlanting
                seasonStats.handbookEntrysStatistics.append(handbookEntryStats)
            }
            if handbookEntries.count > 0{
                seasonStats.averages.averageCash = seasonStats.totalCash/Double(handbookEntries.count)
                seasonStats.averages.averageTrees = seasonStats.totalTrees/handbookEntries.count
                seasonStats.averages.averageDistanceTravelled = seasonStats.totalDistanceTravelled/Double(handbookEntries.count)
                seasonStats.averages.averageTimeSecondsPlanting = seasonStats.totalTimeSecondsPlanting/handbookEntries.count
            }
            seasonsStatistics.append(seasonStats)
        }
    }
    
    ///Reorders items in  collection view when a item is dragged to a new location
    ///- Parameter coordinator: Drop coordinator
    ///- Parameter destinationIndexPath:Index path for location of where the item got dropped
    ///- Parameter collectionView: UICollectionView from where the drop occured
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView){
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath{
            collectionView.performBatchUpdates({
                self.cardIndexs.remove(at: sourceIndexPath.item)
                self.cardIndexs.insert(item.dragItem.localObject as! Int, at: destinationIndexPath.item)
                let tempGraphSeasonIndex = Int(self.graphSeasonsIndexs[sourceIndexPath.item])
                self.graphSeasonsIndexs.remove(at: sourceIndexPath.item)
                self.graphSeasonsIndexs.insert(tempGraphSeasonIndex, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            })
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
        saveCards()
    }
    
    ///Save all the cards in the UICollectionView
    fileprivate func saveCards(){
        userDefaults.set(cardIndexs, forKey:"cardsOrderArray")
        userDefaults.set(graphSeasonsIndexs, forKey:"seasonsOrderArray")
    }
    
    ///Gets the order of cards that was saved in user personal storage
    fileprivate func getOrderOfCards() -> [Int]{
        if let tempItems = userDefaults.object(forKey: "cardsOrderArray"){
            let items = tempItems as! NSArray
            return items as! [Int]
        }
        return [0,1,2,3,4,5,6,7,8,9,10]
    }
    
    ///Gets the graph for each card that was saved in user personal storage
    ///- Returns: Order of graphs for each card
    fileprivate func getOrderOfGraphSeasons() -> [Int]{
        if let tempSeasons = userDefaults.object(forKey: "seasonsOrderArray"){
            let seasons = tempSeasons as! NSArray
            return seasons as! [Int]
        }
        return [0,0,0,0,0,0,0,0,0,0,0]
    }
    
    ///Opens SeasonsPickerViewModalViewController for changing graph
    ///- Parameter sender: Hamburger menu on card
    @objc func hamburgerMenuTapped(sender: UIButton) {
        if seasons.count > 0{
            lookingAtGraphWithIndex = sender.tag
            let seasonsPickerViewModal = SeasonsPickerViewModalViewController(seasonSelected: graphSeasonsIndexs[lookingAtGraphWithIndex])
            seasonsPickerViewModal.delegate = self
            seasonsPickerViewModal.modalPresentationStyle = .popover
            seasonsPickerViewModal.setUpUIPopUpController(barButtonItem: nil, sourceView: sender)
            present(seasonsPickerViewModal, animated: true)
        }
        else{
            let alertController = UIAlertController(title: "Error: No Seasons", message: "Please create a season", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    ///Changes string of label inside a ChartDataEntry
    ///- Parameter value: Hamburger menu on card
    ///- Parameter entry: ChartDataEntry in graph
    ///- Parameter dataSetIndex: Location of data entry in graph
    ///- Parameter viewPortHandler: Contains information about viewport settings
    ///- Returns: new label for ChartDataEntry
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let (h, m, _) = GeneralFunctions.secondsToHoursMinutesSeconds(seconds: Int(value))
        let timerString = String(h) + ":" + String(m)
        return timerString
    }

}

///Functionality required for using UICollectionViewDelegateFlowLayout, and UICollectionViewDataSource
extension StatisticsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    ///Asks the delegate for the size of the specified item’s cell
    ///- Parameter CollectionView: The collection view object displaying the flow layout.
    ///- Parameter collectionViewLayout: Layout object requesting information
    ///- Parameter sizeForItemAt: Size for the items at that indexPath
    ///- Parameter indexPath: Index path of item
    ///- Returns: The width and height of the specified item. Both values must be greater than 0.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cardIndexs[indexPath.row] == 0{
            return .init(width: backgroundView.safeAreaFrame.width*0.9, height: view.frame.height*0.15)
        }
        else if cardIndexs[indexPath.row] == 4 || cardIndexs[indexPath.row] == 6{
            return .init(width: backgroundView.safeAreaFrame.width*0.9, height: view.frame.height*0.25)
        }
        else if cardIndexs[indexPath.row] == 1{
            return .init(width: backgroundView.safeAreaFrame.width*0.9, height: view.frame.height*0.165)
        }
        else{
            return  .init(width: backgroundView.safeAreaFrame.width*0.9, height: view.frame.height*0.4 + 50)
        }
    }
    
    ///Asks your data source object for the number of items in the specified section.
    ///- Parameter CollectionView: The collection view object displaying the flow layout.
    ///- Parameter numberOfItemsInSection: Given number of items to be insection
    ///- Returns: Number of items to be insection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardIndexs.count
    }
    
    ///Asks your data source object for the cell that corresponds to the specified item in the collection view.
    ///- Parameter CollectionView: The collection view object displaying the flow layout.
    ///- Parameter indexPath: Index path that specifies location of item
    ///- Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cardIndexs[indexPath.row] == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TotalCashCell", for: indexPath) as! TotalCashCell
            cell.hamburgerMenu.isHidden = true
            
            var totalCash : Double = 0
            var totalTrees : Int = 0
            
            for seasonStats in seasonsStatistics{
                totalCash += seasonStats.totalCash
                totalTrees += seasonStats.totalTrees
            }
            cell.totalCashAmountLabel.text = totalCash.toCurrency()
            cell.totalTreesAmountLabel.text = String(totalTrees)
           return cell
        }
        else if cardIndexs[indexPath.row] == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OneTotalCell", for: indexPath) as! OneTotalCell
            cell.totalLabel.text = "Time Spent Planting"
            cell.titleLabel.text = "Seasons"
            cell.hamburgerMenu.addTarget(self, action: #selector(hamburgerMenuTapped), for: .touchUpInside)
            cell.hamburgerMenu.tag = indexPath.row
            if seasons.count > 0{
                cell.seasonTitleLabel.text = seasons[graphSeasonsIndexs[indexPath.row]].title
                for seasonStats in seasonsStatistics{
                    if seasonStats.seasonName == cell.seasonTitleLabel.text{
                        let (d,h,m,s) = GeneralFunctions.secondsToDaysHoursMinutesSeconds(seconds: seasonStats.totalTimeSecondsPlanting)
                        cell.largeTotalLabel.text = (d < 10 ? "0" : "") + String(d) + " : " + (h < 10 ? "0" : "") + String(h) + " : " + (m < 9 ? "0" : "") + String(m) + " : " + (s < 9 ? "0" : "") + String(s)
                        cell.largeTotalLabel.textColor = StatisticColors.time
                    }
                }
            }
            else{
                cell.largeTotalLabel.text = "00:00:00:00"
                cell.largeTotalLabel.textColor = StatisticColors.time
                cell.seasonTitleLabel.text = "Season"
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            setUpGraphCell(cell: cell, indexPath: indexPath, graphTitle: "Days", graphSubTitle: "Cash")
            if seasons.count > 0{
                reloadLineGraphCell(cell: cell, indexPath: indexPath)
                for seasonStats in seasonsStatistics{
                    if seasonStats.seasonName == cell.seasonTitle.text{
                        if seasonStats.handbookEntrysStatistics.count <= 4{
                            cell.lineChart.data = nil
                        }
                        else{
                            var cashEntries = [ChartDataEntry]()
                            var dates = [String]()
                            for i in 0..<seasonStats.handbookEntrysStatistics.count{
                                print(seasonStats.handbookEntrysStatistics[i])
                                dates.append(GeneralFunctions.getDate(from: seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].date))
                                cashEntries.append(ChartDataEntry(x: Double(i), y: Double(seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].totalCash).round(to: 2)))
                            }
                            setUpLineChart(cell: cell, entries: cashEntries, entryLabel: "Cash", colors: [NSUIColor.init(cgColor: StatisticColors.cash.cgColor)], xAxisLabels: dates, showGraphOnIndex: Double(seasonStats.handbookEntrysStatistics.count))
                        }
                    }
                }
            }else{
                cell.seasonTitle.text = "Season"
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            setUpGraphCell(cell: cell, indexPath: indexPath, graphTitle: "Days", graphSubTitle: "Trees")
            if seasons.count > 0{
                reloadLineGraphCell(cell: cell, indexPath: indexPath)
                for seasonStats in seasonsStatistics{
                    if seasonStats.seasonName == cell.seasonTitle.text{
                        if seasonStats.handbookEntrysStatistics.count <= 4{
                            cell.lineChart.data = nil
                        }
                        else{
                            var treesEntries = [ChartDataEntry]()
                            var dates = [String]()
                            for i in 0..<seasonStats.handbookEntrysStatistics.count{
                                dates.append(GeneralFunctions.getDate(from: seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].date))
                                treesEntries.append(ChartDataEntry(x: Double(i), y: Double(seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].totalTrees).round(to: 0)))
                            }
                            setUpLineChart(cell: cell, entries: treesEntries, entryLabel: "Trees", colors: [NSUIColor.init(cgColor: StatisticColors.trees.cgColor)], xAxisLabels: dates, showGraphOnIndex: Double(seasonStats.handbookEntrysStatistics.count))
                        }
                    }
                }
            }else{
                cell.seasonTitle.text = "Season"
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 4{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
            
            cell.hamburgerMenu.addTarget(self, action: #selector(hamburgerMenuTapped), for: .touchUpInside)
            cell.hamburgerMenu.tag = indexPath.row
            cell.hamburgerMenu.isHidden = false
            cell.titleLabel.text = "Days"
            if seasons.count > 0{
                cell.seasonTitleLabel.text = seasons[graphSeasonsIndexs[indexPath.row]].title
            }
            else{
                clearOverallStatsCell(cell: cell)
            }
            
            for seasonStats in seasonsStatistics{
                if seasonStats.seasonName == cell.seasonTitleLabel.text{
                    if let bestCashStats = seasonStats.bestEntryStats{
                        cell.bestCashLabel.text = bestCashStats.totalCash.toCurrency()
                        cell.bestTreesLabel.text = String(bestCashStats.totalTrees)
                    }
                    cell.averageCashLabel.text = seasonStats.averages.averageCash.toCurrency()
                    cell.averageTreesLabel.text = String(seasonStats.averages.averageTrees)
                }
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 5{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PieChartCell", for: indexPath) as! PieChartCell
            cell.reloadInputViews()
            cell.hamburgerMenu.addTarget(self, action: #selector(hamburgerMenuTapped), for: .touchUpInside)
            cell.hamburgerMenu.tag = indexPath.row
            cell.graphTitle.text = "Seasons"
            cell.graphSubTitle.text = "Cash vs Trees"
            if seasons.count > 0{
                cell.seasonTitle.text = seasons[graphSeasonsIndexs[indexPath.row]].title
                cell.pieChart.clearValues()
                cell.pieChart.clear()
                cell.pieChart.reloadInputViews()
                for seasonStats in seasonsStatistics{
                    if seasonStats.seasonName == cell.seasonTitle.text{
                        if seasonStats.handbookEntrysStatistics.count == 0{
                            cell.pieChart.data = nil
                        }
                        else{
                            var chartEntries = [ChartDataEntry]()
                            chartEntries.append(PieChartDataEntry(value: Double(seasonStats.totalCash.round(to: 2)), label: "Cash"))
                            chartEntries.append(PieChartDataEntry(value: Double(seasonStats.totalTrees), label: "Trees"))
                            let pieChartDataSet = PieChartDataSet(entries: chartEntries, label: nil)
                            pieChartDataSet.colors = [ NSUIColor.init(cgColor: StatisticColors.cash.cgColor), NSUIColor.init(cgColor: StatisticColors.trees.cgColor)]
                            pieChartDataSet.valueFont = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraExtraSmall)) ?? UIFont.systemFont(ofSize: 12)
                            
                            let dataChart = PieChartData(dataSet: pieChartDataSet)
                            dataChart.setDrawValues(true)
                            cell.pieChart.drawEntryLabelsEnabled = false
                                
                            cell.pieChart.data = dataChart
                            cell.pieChart.backgroundColor = .clear
                            cell.pieChart.holeColor = .clear
                        }
                    }
                }
            }else{
                cell.seasonTitle.text = "Season"
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 6{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
            cell.hamburgerMenu.isHidden = true
            cell.seasonTitleLabel.text = ""
            cell.titleLabel.text = "Seasons"
            
            var currentBestSeasonCash : Double = 0
            var totalCashFromAllSeasons : Double = 0
            var totalTreesFromAllSeasons : Int = 0
            
            for seasonStats in seasonsStatistics{
                if seasonStats.totalCash > currentBestSeasonCash{
                    currentBestSeasonCash = seasonStats.totalCash
                    cell.bestCashLabel.text = seasonStats.totalCash.toCurrency()
                    cell.bestTreesLabel.text = String(seasonStats.totalTrees)
                }
                totalCashFromAllSeasons += seasonStats.totalCash
                totalTreesFromAllSeasons += seasonStats.totalTrees
            }
            
            if seasonsStatistics.count > 0{
                cell.averageCashLabel.text = (totalCashFromAllSeasons/Double(seasonsStatistics.count)).toCurrency()
                cell.averageTreesLabel.text = String(totalTreesFromAllSeasons/seasonsStatistics.count)
            }
            else{
                clearOverallStatsCell(cell: cell)
                cell.seasonTitleLabel.text = ""
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 7{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            setUpGraphCell(cell: cell, indexPath: indexPath, graphTitle: "Days", graphSubTitle: "Steps")
            if seasons.count > 0{
                reloadLineGraphCell(cell: cell, indexPath: indexPath)
                for seasonStats in seasonsStatistics{
                    if seasonStats.seasonName == cell.seasonTitle.text{
                        if seasonStats.handbookEntrysStatistics.count <= 4{
                            cell.lineChart.data = nil
                        }
                        else{
                            var stepsEntries = [ChartDataEntry]()
                            var dates = [String]()
                            for i in 0..<seasonStats.handbookEntrysStatistics.count{
                                dates.append(GeneralFunctions.getDate(from: seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].date))
                                stepsEntries.append(ChartDataEntry(x: Double(i), y: Double(Int(seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].totalDistanceTravelled*100)/stepDistance)))
                            }
                            setUpLineChart(cell: cell, entries: stepsEntries, entryLabel: "Steps", colors: [NSUIColor.init(cgColor: StatisticColors.steps.cgColor)], xAxisLabels: dates, showGraphOnIndex: Double(seasonStats.handbookEntrysStatistics.count))
                        }
                    }
                }
            }else{
                cell.seasonTitle.text = "Season"
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 8{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            setUpGraphCell(cell: cell, indexPath: indexPath, graphTitle: "Days", graphSubTitle: "Distance Travelled")
            if seasons.count > 0{
                reloadLineGraphCell(cell: cell, indexPath: indexPath)
                for seasonStats in seasonsStatistics{
                    if seasonStats.seasonName == cell.seasonTitle.text{
                        if seasonStats.handbookEntrysStatistics.count <= 4{
                            cell.lineChart.data = nil
                        }
                        else{
                            var distanceEntries = [ChartDataEntry]()
                            var dates = [String]()
                            for i in 0..<seasonStats.handbookEntrysStatistics.count{
                                dates.append(GeneralFunctions.getDate(from: seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].date))
                                distanceEntries.append(ChartDataEntry(x: Double(i), y: Double(seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].totalDistanceTravelled/1000).round(to: 3)))
                            }
                            setUpLineChart(cell: cell, entries: distanceEntries, entryLabel: "Distance", colors: [NSUIColor.init(cgColor: StatisticColors.distance.cgColor)], xAxisLabels: dates, showGraphOnIndex: Double(seasonStats.handbookEntrysStatistics.count))
                        }
                    }
                }
            }else{
                cell.seasonTitle.text = "Season"
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 9{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalBarGraphCell", for: indexPath) as! HorizontalBarGraphCell
            cell.hamburgerMenu.isHidden = true
            cell.graphTitle.text = "Seasons"
            cell.graphSubTitle.text = "Distance Travelled"
            cell.seasonTitle.text = ""
            cell.barChart.clearValues()
            cell.barChart.clear()
            cell.barChart.reloadInputViews()
            cell.barChart.isUserInteractionEnabled = true
            cell.graphView.isUserInteractionEnabled = true
            if seasonsStatistics.count == 0{
                cell.barChart.data = nil
            }
            else{
                var dataEntries = [ChartDataEntry]()
                var labels = [String]()
                for i in 0..<seasonsStatistics.count{
                    dataEntries.append(BarChartDataEntry(x: Double(i), y: seasonsStatistics[i].totalDistanceTravelled))
                    labels.append(seasonsStatistics[i].seasonName)
                }
                let dataSet = BarChartDataSet(entries: dataEntries, label: nil)
                dataSet.colors = [NSUIColor.init(cgColor: StatisticColors.distance.cgColor)]
                cell.barChart.xAxis.labelCount = labels.count
                cell.barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
                let data = BarChartData(dataSet: dataSet)
                data.barWidth = 0.35
                cell.barChart.data = data
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for: indexPath) as! LineGraphCell
            setUpGraphCell(cell: cell, indexPath: indexPath, graphTitle: "Days", graphSubTitle: "Time Spent Planting")
            if seasons.count > 0{
                reloadLineGraphCell(cell: cell, indexPath: indexPath)
                for seasonStats in seasonsStatistics{
                    if seasonStats.seasonName == cell.seasonTitle.text{
                        if seasonStats.handbookEntrysStatistics.count <= 4{
                            cell.lineChart.data = nil
                        }
                        else{
                            if seasonStats.seasonName == cell.seasonTitle.text{
                                var distanceEntries = [ChartDataEntry]()
                                var dates = [String]()
                                for i in 0..<seasonStats.handbookEntrysStatistics.count{
                                    dates.append(GeneralFunctions.getDate(from: seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].date))
                                    distanceEntries.append(ChartDataEntry(x: Double(i), y: Double(seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].totalTimeSecondsPlanting)))
                                }
                                setUpLineChart(cell: cell, entries: distanceEntries, entryLabel: "Time: H:M", colors: [NSUIColor.init(cgColor: StatisticColors.time.cgColor)], xAxisLabels: dates, showGraphOnIndex: Double(seasonStats.handbookEntrysStatistics.count))
                                cell.lineChart.lineData?.dataSets[0].valueFormatter = self
                            }
                        }
                    }
                }
            }else{
                cell.seasonTitle.text = "Season"
            }
            return cell
        }
    }
    
    ///Clears overall stats cell
    ///- Parameter cell: cell to be cleared
    func clearOverallStatsCell(cell: OverallStatsCell){
        cell.bestCashLabel.text = "$0.00"
        cell.bestTreesLabel.text = "0"
        cell.averageCashLabel.text = "$0.00"
        cell.averageTreesLabel.text = "0"
        cell.seasonTitleLabel.text = "Season"
    }
    
    /// Sets up the graph cell with general information
    ///- Parameter cell: cell to be filled with information
    ///- Parameter indexPath: used for the tag
    ///- Parameter graphTitle: graphs title in cell
    ///- Parameter graphSubTitle: graphs sub-title in cell
    func setUpGraphCell(cell: GraphCardCell, indexPath: IndexPath, graphTitle: String, graphSubTitle: String){
        cell.reloadInputViews()
        cell.hamburgerMenu.addTarget(self, action: #selector(hamburgerMenuTapped), for: .touchUpInside)
        cell.hamburgerMenu.tag = indexPath.row
        cell.graphTitle.text = graphTitle
        cell.graphSubTitle.text = graphSubTitle
    }
    
    /// Clears and reloads the linegraph in a cell
    ///- Parameter cell: cell with line graph
    ///- Parameter indexPath: used for finding out which season is to be used
    func reloadLineGraphCell(cell: LineGraphCell, indexPath: IndexPath){
        cell.seasonTitle.text = seasons[graphSeasonsIndexs[indexPath.row]].title
        cell.lineChart.clearValues()
        cell.lineChart.clear()
        cell.lineChart.reloadInputViews()
    }
    
    /// Sets up general line chart
    ///- Parameter cell:cell that contains line graph
    ///- Parameter entries: all entries to be in chart
    ///- Parameter entryLabel:label to represent entries
    ///- Parameter colors: colors to be used for entries
    ///- Parameter xAxisLabels: labels for xAcis
    ///- Parameter showGraphOnIndex: centers view of graph for this index
    func setUpLineChart(cell: LineGraphCell, entries: [ChartDataEntry], entryLabel: String, colors: [NSUIColor], xAxisLabels: [String], showGraphOnIndex: Double){
        let dataSet = LineChartDataSet(entries: entries, label: entryLabel)
        dataSet.colors = colors
        dataSet.circleColors = colors
                            
        let dataChart = LineChartData()
        dataChart.setDrawValues(true)
        dataChart.addDataSet(dataSet)

        cell.lineChart.data = dataChart
        cell.lineChart.setVisibleXRangeMaximum(ChartNumbers.requiredInputValuesAmount)
        cell.lineChart.xAxis.labelCount = xAxisLabels.count
        cell.lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        cell.lineChart.moveViewToX(showGraphOnIndex)
    }
}

///Functionality required for using UICollectionViewDragDelegate
extension StatisticsViewController: UICollectionViewDragDelegate{
    ///Provides the initial set of items (if any) to drag.
    ///- Parameter collectionView: The collection view from which the drag operation originated..
    ///- Parameter session: The current drag session object.
    ///- Parameter indexPath: The index path of the item to drag.
    ///- Returns: An array of UIDragItem objects containing the details of the items to drag. Return an empty array to prevent the item from being dragged.
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.cardIndexs[indexPath.row]
        let itemProvider = NSItemProvider(object: String(item) as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

///Functionality required for using UICollectionViewDropDelegates
extension StatisticsViewController: UICollectionViewDropDelegate{
    ///Tells your delegate to incorporate the drop data into the collection view.
    ///- Parameter collectionView: The collection view that received the drop.
    ///- Parameter coordinater: The coordinator object to use when handling the drop. Use this object to coordinate your custom behavior with the default behavior of the collection view.
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath{
            destinationIndexPath = indexPath
        } else{
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row-1, section: 0)
        }
        
        if coordinator.proposal.operation == .move{
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
        
    }
    
    ///Tells your delegate that the position of the dragged data over the collection view changed.
    ///- Parameter collectionView: The collection view that’s tracking the dragged content.
    ///- Parameter session: The drop session object containing information about the type of data being dragged.
    ///- Parameter destinationIndexPath: The index path at which the content would be dropped.
    ///- Returns: Your proposal for how to handle the content if it is dropped at the specified location.
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag{
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
}

///Functionality required for using SeasonsPickerViewModalDelegate
extension StatisticsViewController: SeasonsPickerViewModalDelegate{
    ///Select season and change all graphs
    ///- Parameter indexOfSeason: Index of season in all seasons
    ///- Parameter changeAllGraphs: Boolean to change all graphs or just one selected
    func selectSeason(indexOfSeason: Int, changeAllGraphs: Bool) {
        if changeAllGraphs {
            for i in 0..<graphSeasonsIndexs.count{
                graphSeasonsIndexs[i] = indexOfSeason
            }
            collectInformation()
            cardsCollectionView.reloadData()
            print("Reloaded All Cards")
        }
        else{
            graphSeasonsIndexs[lookingAtGraphWithIndex] = indexOfSeason
            let indexPath = IndexPath(item: lookingAtGraphWithIndex, section: 0)
            cardsCollectionView.reloadItems(at: [indexPath])
        }
        saveCards()
    }
}
