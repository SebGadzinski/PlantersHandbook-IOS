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

class StatisticsViewController: StatisticsView, IValueFormatter {
    
    fileprivate var seasons: Results<Season>
    fileprivate var longPressGesture = UILongPressGestureRecognizer()
    fileprivate let userDefaults = UserDefaults.standard

    fileprivate var cardIndexs : [Int] = [0,1,2,3,4,5,6,7,8,9]
    fileprivate var graphSeasonsIndexs : [Int] = [0,0,0,0,0,0,0,0,0,0]
    fileprivate var lookingAtGraphWithIndex = 0
    fileprivate var seasonsStatistics : [SeasonStatistics] = []
    fileprivate var justInitalized = true
    
    private let refreshControl = UIRefreshControl()
    
    required init() {
        seasons = realmDatabase.getSeasonRealm(predicate: nil).sorted(byKeyPath: "_id")
        super.init(nibName: nil, bundle: nil)
        cardIndexs = getOrderOfCards()
        graphSeasonsIndexs = getOrderOfGraphSeasons()
        justInitalized = true
        collectInformation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    internal override func configureViews() {
        super.configureViews()
        cardsCollectionView.delegate = self
        cardsCollectionView.dataSource = self
        cardsCollectionView.dragDelegate = self
        cardsCollectionView.dropDelegate = self
    }
    
    internal override func setActions() {
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        setUpRefreshControl()
    }
    
    private func setUpRefreshControl(){
        cardsCollectionView.alwaysBounceVertical = true
        cardsCollectionView.refreshControl = refreshControl
    }
    
    @objc fileprivate func didPullToRefresh(_ sender: Any) {
        collectInformation()
        cardsCollectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    fileprivate func collectInformation(){
        if justInitalized{
            justInitalized = false
        }
        else{
            seasons = realmDatabase.getSeasonRealm(predicate: nil).sorted(byKeyPath: "_id")
        }
        for i in 0..<graphSeasonsIndexs.count{
            if seasons.count == graphSeasonsIndexs[i]{
                graphSeasonsIndexs[i] = 0
            }
        }
        
        seasonsStatistics.removeAll()
        for season in seasons{
            var seasonStats = SeasonStatistics(seasonName: String(season.title))
            
            let handbookEntries = realmDatabase.getHandbookEntryRealm(predicate: .init(format: "seasonId = %@", season._id)).sorted(byKeyPath: "date", ascending: false)
            for handbookEntry in handbookEntries{
                var handbookEntryStats = HandbookEntryStatistics(date: handbookEntry.date)
                
                let blocks = realmDatabase.getBlockRealm(predicate: .init(format: "entryId = %@", handbookEntry._id))
                for block in blocks{
                    let subBlocks = realmDatabase.getSubBlockRealm(predicate: .init(format: "blockId = %@", block._id))
                    for subBlock in subBlocks{
                        let caches = realmDatabase.getCacheRealm(predicate: .init(format: "subBlockId = %@", subBlock._id))
                        for cache in caches{
                            var prevCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                            
                            cache.totalCashPerTreeTypes.forEach{
                                handbookEntryStats.totalCash += $0
        
                            }
                            cache.totalTreesPerTreeTypes.forEach{
                                handbookEntryStats.totalTrees += $0
                            }
                            cache.secondsPlanted.forEach{
                                handbookEntryStats.totalTrees += $0
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
    
    fileprivate func saveCards(){
        userDefaults.set(cardIndexs, forKey:"cardsOrderArray")
        userDefaults.set(graphSeasonsIndexs, forKey:"seasonsOrderArray")
    }
    
    fileprivate func getOrderOfCards() -> [Int]{
        if let tempItems = userDefaults.object(forKey: "cardsOrderArray"){
            let items = tempItems as! NSArray
            return items as! [Int]
        }
        return [0,1,2,3,4,5,6,7,8,9]
    }
    
    fileprivate func getOrderOfGraphSeasons() -> [Int]{
        if let tempSeasons = userDefaults.object(forKey: "seasonsOrderArray"){
            let seasons = tempSeasons as! NSArray
            return seasons as! [Int]
        }
        return [0,0,0,0,0,0,0,0,0,0]
    }
    
    @objc func hamdbugerMenuTapped(sender: UIButton) {
        print("SENDING : \(sender.tag)")
        print(graphSeasonsIndexs)
        if seasons.count > 0{
            lookingAtGraphWithIndex = sender.tag
            let seasonsPickerViewModal = SeasonsPickerViewModalViewController(seasonSelected: graphSeasonsIndexs[lookingAtGraphWithIndex])
            seasonsPickerViewModal.delegate = self
            seasonsPickerViewModal.modalPresentationStyle = .popover
            present(seasonsPickerViewModal, animated: true)
        }
        else{
            let alertController = UIAlertController(title: "Error: No Seasons", message: "Please create a season", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let (h, m, _) = GeneralFunctions.secondsToHoursMinutesSeconds(seconds: Int(value))
        let timerString = String(h) + ":" + String(m)
        return timerString
    }

}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cardIndexs[indexPath.row] == 0{
            return .init(width: backgroundView.safeAreaFrame.width*0.9, height: view.frame.height*0.15)
        }
        else if cardIndexs[indexPath.row] == 3 || cardIndexs[indexPath.row] == 5{
            return .init(width: backgroundView.safeAreaFrame.width*0.9, height: view.frame.height*0.25)
        }
        else if cardIndexs[indexPath.row] == 9{
            return .init(width: backgroundView.safeAreaFrame.width*0.9, height: view.frame.height*0.18)
        }
        else{
            return  .init(width: backgroundView.safeAreaFrame.width*0.9, height: view.frame.height*0.4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardIndexs.count
    }
    
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
            print("Entry Cash")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            createGraphCell(cell: cell, indexPath: indexPath, graphTitle: "Entrys", graphSubTitle: "Cash")
            if seasons.count > 0{
                reloadLineGraphCell(cell: cell, indexPath: indexPath)
                for seasonStats in seasonsStatistics{
                    if seasonStats.seasonName == cell.seasonTitle.text{
                        print("Starting Entrys Cash Caclulations")
                        
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
                            setUpLineChart(cell: cell, entries: cashEntries, entryLabel: "Cash", colors: [NSUIColor.init(cgColor: StatisticColors.cash.cgColor)], datesForXAxis: dates, lastIndex: Double(seasonStats.handbookEntrysStatistics.count))
                        }
                        print("Finished Entrys Cash  Caclulations")
                    }
                }
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            createGraphCell(cell: cell, indexPath: indexPath, graphTitle: "Entrys", graphSubTitle: "Trees")
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
                            setUpLineChart(cell: cell, entries: treesEntries, entryLabel: "Trees", colors: [NSUIColor.init(cgColor: StatisticColors.trees.cgColor)], datesForXAxis: dates, lastIndex: Double(seasonStats.handbookEntrysStatistics.count))
                        }
                    }
                }
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
            
            cell.hamburgerMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
            cell.hamburgerMenu.tag = indexPath.row
            cell.hamburgerMenu.isHidden = false
            cell.titleLabel.text = "Entrys"
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
        else if cardIndexs[indexPath.row] == 4{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PieChartCell", for: indexPath) as! PieChartCell
            cell.reloadInputViews()
            cell.hamburgerMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
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
                            chartEntries.append(PieChartDataEntry(value: Double(seasonStats.totalCash), label: "Cash"))
                            chartEntries.append(PieChartDataEntry(value: Double(seasonStats.totalTrees), label: "Trees"))
                            let pieChartDataSet = PieChartDataSet(entries: chartEntries, label: nil)
                            pieChartDataSet.colors = [ NSUIColor.init(cgColor: StatisticColors.cash.cgColor), NSUIColor.init(cgColor: StatisticColors.trees.cgColor)]
                            
                            let dataChart = PieChartData(dataSet: pieChartDataSet)
                            
                            cell.pieChart.data = dataChart
                            cell.pieChart.backgroundColor = .clear
                            cell.pieChart.holeColor = .clear
                        }
                    }
                }
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 5{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
            cell.seasonTitleLabel.text = ""
            cell.hamburgerMenu.isHidden = true
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
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 6{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for: indexPath) as! LineGraphCell
            createGraphCell(cell: cell, indexPath: indexPath, graphTitle: "Entrys", graphSubTitle: "Distance Travelled")
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
                                    distanceEntries.append(ChartDataEntry(x: Double(i), y: Double(seasonStats.handbookEntrysStatistics[seasonStats.handbookEntrysStatistics.count-i-1].totalDistanceTravelled/1000).round(to: 3)))
                                }
                                setUpLineChart(cell: cell, entries: distanceEntries, entryLabel: "Distance: KM", colors: [NSUIColor.init(cgColor: StatisticColors.distance.cgColor)], datesForXAxis: dates, lastIndex: Double(seasonStats.handbookEntrysStatistics.count))
                            }
                        }
                    }
                }
            }
            return cell
        }
        else if cardIndexs[indexPath.row] == 7{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalBarGraphCell", for: indexPath) as! HorizontalBarGraphCell
            cell.hamburgerMenu.isHidden = true
            cell.graphTitle.text = "Seasons"
            cell.graphSubTitle.text = "Distance Travelled"
            cell.seasonTitle.text = ""
            cell.barChart.clearValues()
            cell.barChart.clear()
            cell.barChart.reloadInputViews()
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
        else if cardIndexs[indexPath.row] == 8 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for: indexPath) as! LineGraphCell
            createGraphCell(cell: cell, indexPath: indexPath, graphTitle: "Entrys", graphSubTitle: "Time Spent Planting")
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
                                setUpLineChart(cell: cell, entries: distanceEntries, entryLabel: "Time: H:M", colors: [NSUIColor.init(cgColor: StatisticColors.time.cgColor)], datesForXAxis: dates, lastIndex: Double(seasonStats.handbookEntrysStatistics.count))
                                cell.lineChart.lineData?.dataSets[0].valueFormatter = self
                            }
                        }
                    }
                }
            }
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OneTotalCell", for: indexPath) as! OneTotalCell
            cell.totalLabel.text = "Time Spent Planting"
            cell.titleLabel.text = "Seasons"
            cell.hamburgerMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
            cell.hamburgerMenu.tag = indexPath.row
            cell.seasonTitleLabel.text = seasons[graphSeasonsIndexs[indexPath.row]].title
            if seasons.count > 0{
                for seasonStats in seasonsStatistics{
                    if seasonStats.seasonName == cell.seasonTitleLabel.text{
                        let (h,m,s) = GeneralFunctions.secondsToHoursMinutesSeconds(seconds: seasonStats.totalTimeSecondsPlanting)
                        cell.largeTotalLabel.text = String(h) + " : " + (m < 9 ? "0" : "") + String(m) + " : " + (s < 9 ? "0" : "") + String(s)
                        cell.largeTotalLabel.textColor = .magenta
                    }
                }
            }
            return cell
        }
    }
    func clearOverallStatsCell(cell: OverallStatsCell){
        cell.bestCashLabel.text = "$0.00"
        cell.bestTreesLabel.text = "0"
        cell.averageCashLabel.text = "$0.00"
        cell.averageTreesLabel.text = "0"
    }
    
    func createGraphCell(cell: GraphCardCell, indexPath: IndexPath, graphTitle: String, graphSubTitle: String){
        cell.reloadInputViews()
        cell.hamburgerMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
        cell.hamburgerMenu.tag = indexPath.row
        cell.graphTitle.text = graphTitle
        cell.graphSubTitle.text = graphSubTitle
    }
    
    func reloadLineGraphCell(cell: LineGraphCell, indexPath: IndexPath){
        cell.seasonTitle.text = seasons[graphSeasonsIndexs[indexPath.row]].title
        cell.lineChart.clearValues()
        cell.lineChart.clear()
        cell.lineChart.reloadInputViews()
    }
    
    func setUpLineChart(cell: LineGraphCell, entries: [ChartDataEntry], entryLabel: String, colors: [NSUIColor], datesForXAxis: [String], lastIndex: Double){
        let dataSet = LineChartDataSet(entries: entries, label: entryLabel)
        dataSet.colors = colors
        dataSet.circleColors = colors
                            
        let dataChart = LineChartData()
        dataChart.addDataSet(dataSet)
        dataChart.setDrawValues(true)
        
        cell.lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: datesForXAxis)
        cell.lineChart.xAxis.labelCount = datesForXAxis.count
        cell.lineChart.xAxis.spaceMin = 0.5
        cell.lineChart.xAxis.spaceMax = 0.5
        cell.lineChart.moveViewToX(lastIndex)
        cell.lineChart.data = dataChart
    }
    
}

extension StatisticsViewController: UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.cardIndexs[indexPath.row]
        let itemProvider = NSItemProvider(object: String(item) as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension StatisticsViewController: UICollectionViewDropDelegate{
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
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag{
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    
}

extension StatisticsViewController: SeasonsPickerViewModalDelegate{
    func selectSeason(indexOfSeason: Int, changeAllGraphs: Bool) {
        if changeAllGraphs {
            for i in 0..<graphSeasonsIndexs.count{
                graphSeasonsIndexs[i] = indexOfSeason
            }
            cardsCollectionView.reloadData()
            print("reloaded All")
        }
        else{
            graphSeasonsIndexs[lookingAtGraphWithIndex] = indexOfSeason
            let indexPath = IndexPath(item: lookingAtGraphWithIndex, section: 0)
            cardsCollectionView.reloadItems(at: [indexPath])
            print(graphSeasonsIndexs)
        }
        saveCards()
    }
}
