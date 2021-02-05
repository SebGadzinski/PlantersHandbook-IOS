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

class StatisticsVC: ProgramicVC {
    
    var notificationToken: NotificationToken?
    var seasons: Results<Season>
    let cardsCollectionView: UICollectionView = PH_CollectionView_Statistics()
    var longPressGesture = UILongPressGestureRecognizer()
    let userDefaults = UserDefaults.standard

    var items : [Int] = [0,1,2,3,4,5,6,7]
    var graphSeasonsIndexs : [Int] = [0,0,0,0,0,0,0,0]
    var lookingAtGraphWithIndex = 0
    var seasonsStatistics : [SeasonStatistics] = []
    var justInitalized = true
    
    private let refreshControl = UIRefreshControl()
    
    required init() {
        seasons = realmDatabase.getSeasonRealm(predicate: nil).sorted(byKeyPath: "_id")
        super.init(nibName: nil, bundle: nil)
        items = getOrderOfCards()
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

    override func configureViews() {
        bgView.addSubview(cardsCollectionView)
        cardsCollectionView.fillSafeSuperView(to: bgView)
        cardsCollectionView.delegate = self
        cardsCollectionView.dataSource = self
        cardsCollectionView.dragDelegate = self
        cardsCollectionView.dropDelegate = self
    }
    
    override func setActions() {
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        setUpRefreshControl()
    }
    
    private func setUpRefreshControl(){
        cardsCollectionView.alwaysBounceVertical = true
        cardsCollectionView.refreshControl = refreshControl // iOS 10+
    }
    
    @objc func didPullToRefresh(_ sender: Any) {
        collectInformation()
        cardsCollectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    private func collectInformation(){
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
            var bestTotalCashFromEntry : Double = 0
            
            let handbookEntries = realmDatabase.getHandbookEntryRealm(predicate: .init(format: "seasonId = %@", season._id))
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
                if let bestEntryStats = seasonStats.bestEntryStats{
                    if handbookEntryStats.totalCash > bestTotalCashFromEntry{
                        seasonStats.bestEntryStats = handbookEntryStats
                    }
                }
                else{
                    seasonStats.bestEntryStats = handbookEntryStats
                    bestTotalCashFromEntry = handbookEntryStats.totalCash
                }
                seasonStats.totalCash += handbookEntryStats.totalCash
                seasonStats.totalTrees += handbookEntryStats.totalTrees
                seasonStats.totalDistanceTravelled += handbookEntryStats.totalDistanceTravelled
                seasonStats.handbookEntrysStatistics.append(handbookEntryStats)
            }
            if handbookEntries.count > 0{
                seasonStats.averages.averageCash = seasonStats.totalCash/Double(handbookEntries.count)
                seasonStats.averages.averageTrees = seasonStats.totalTrees/handbookEntries.count
                seasonStats.averages.averageDistanceTravelled = seasonStats.totalDistanceTravelled/Double(handbookEntries.count)
            }
            seasonsStatistics.append(seasonStats)
        }
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView){
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath{
            collectionView.performBatchUpdates({
                self.items.remove(at: sourceIndexPath.item)
                self.items.insert(item.dragItem.localObject as! Int, at: destinationIndexPath.item)
                let tempGraphSeasonIndex = Int(self.graphSeasonsIndexs[sourceIndexPath.item])
                self.graphSeasonsIndexs.remove(at: sourceIndexPath.item)
                self.graphSeasonsIndexs.insert(tempGraphSeasonIndex, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            })
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
        saveOrderOfCards()
    }
    
    func saveOrderOfCards(){
        userDefaults.set(items, forKey:"cardsOrderArray")
        userDefaults.set(graphSeasonsIndexs, forKey:"seasonsOrderArray")
    }
    
    func getOrderOfCards() -> [Int]{
        if let tempItems = userDefaults.object(forKey: "cardsOrderArray"){
            let items = tempItems as! NSArray
            return items as! [Int]
        }
        return [0,1,2,3,4,5,6,7]
    }
    
    func getOrderOfGraphSeasons() -> [Int]{
        if let tempSeasons = userDefaults.object(forKey: "seasonsOrderArray"){
            let seasons = tempSeasons as! NSArray
            return seasons as! [Int]
        }
        return [0,0,0,0,0,0,0,0]
    }
    
    @objc func hamdbugerMenuTapped(sender: UIButton) {
        print("SENDING : \(sender.tag)")
        print(graphSeasonsIndexs)
        if seasons.count > 0{
            lookingAtGraphWithIndex = sender.tag
            let seasonsPickerViewModal = SeasonsPickerViewModal(seasonSelected: graphSeasonsIndexs[lookingAtGraphWithIndex])
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

}

extension StatisticsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if items[indexPath.row] == 0{
            return .init(width: bgView.safeAreaFrame.width*0.9, height: view.frame.height*0.15)
        }
        else if items[indexPath.row] == 3 || items[indexPath.row] == 5{
            return .init(width: bgView.safeAreaFrame.width*0.9, height: view.frame.height*0.25)
        }
        else{
            return  .init(width: bgView.safeAreaFrame.width*0.9, height: view.frame.height*0.4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if items[indexPath.row] == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TotalCashCell", for: indexPath) as! TotalCashCell
            cell.hambugarMenu.isHidden = true
            
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
        else if items[indexPath.row] == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            cell.graphTitle.text = "Entrys"
            cell.graphSubTitle.text = "Cash"
            cell.hambugarMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
            cell.hambugarMenu.tag = indexPath.row
            if seasons.count > 0{
                cell.seasonTitle.text = seasons[graphSeasonsIndexs[indexPath.row]].title
            }
            for seasonStats in seasonsStatistics{
                if seasonStats.seasonName == cell.seasonTitle.text{
                    
                }
            }
            return cell
        }
        else if items[indexPath.row] == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            cell.graphTitle.text = "Entrys"
            cell.graphSubTitle.text = "Trees"
            cell.hambugarMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
            cell.hambugarMenu.tag = indexPath.row
            if seasons.count > 0{
                cell.seasonTitle.text = seasons[graphSeasonsIndexs[indexPath.row]].title
            }
            for seasonStats in seasonsStatistics{
                if seasonStats.seasonName == cell.seasonTitle.text{
                    
                }
            }
            return cell
        }
        else if items[indexPath.row] == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
            cell.hambugarMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
            cell.hambugarMenu.tag = indexPath.row
            cell.hambugarMenu.isHidden = false
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
        else if items[indexPath.row] == 4{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PieChartCell", for: indexPath) as! PieChartCell
            cell.hambugarMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
            cell.hambugarMenu.tag = indexPath.row
            cell.graphTitle.text = "Seasons"
            cell.graphSubTitle.text = "Cash vs Trees"
            if seasons.count > 0{
                cell.seasonTitle.text = seasons[graphSeasonsIndexs[indexPath.row]].title
            }
            for seasonStats in seasonsStatistics{
                if seasonStats.seasonName == cell.seasonTitle.text{
                    
                }
            }
            return cell
        }
        else if items[indexPath.row] == 5{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
            cell.seasonTitleLabel.text = ""
            cell.hambugarMenu.isHidden = true
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
        else if items[indexPath.row] == 6{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for: indexPath) as! LineGraphCell
            
            cell.hambugarMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
            cell.hambugarMenu.tag = indexPath.row
            cell.graphTitle.text = "Entrys"
            cell.graphSubTitle.text = "Distance Travelled"
            if seasons.count > 0{
                cell.seasonTitle.text = seasons[graphSeasonsIndexs[indexPath.row]].title
            }
            for seasonStats in seasonsStatistics{
                if seasonStats.seasonName == cell.seasonTitle.text{
                    
                }
            }
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalBarGraphCell", for: indexPath) as! HorizontalBarGraphCell
            cell.hambugarMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
            cell.hambugarMenu.tag = indexPath.row
            cell.graphTitle.text = "Seasons"
            cell.graphSubTitle.text = "Distance Travelled"
            if seasons.count > 0{
                cell.seasonTitle.text = seasons[graphSeasonsIndexs[indexPath.row]].title
            }
            for seasonStats in seasonsStatistics{

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
}

extension StatisticsVC: UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.items[indexPath.row]
        let itemProvider = NSItemProvider(object: String(item) as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension StatisticsVC: UICollectionViewDropDelegate{
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

extension StatisticsVC: SeasonsPickerViewModal_Delegate{
    func selectSeason(indexOfSeason: Int, changeAllGraphs: Bool) {
        if changeAllGraphs {
            for i in 0..<graphSeasonsIndexs.count{
                graphSeasonsIndexs[i] = indexOfSeason
            }
            print("ALLL THINGS MUST CHANGE")
            cardsCollectionView.reloadData()
        }
        else{
            print("ONLY ONE THING CHANGE \(lookingAtGraphWithIndex)")
            graphSeasonsIndexs[lookingAtGraphWithIndex] = indexOfSeason
            let indexPath = IndexPath(item: lookingAtGraphWithIndex, section: 0)
            cardsCollectionView.reloadItems(at: [indexPath])
            print(graphSeasonsIndexs)
        }
        saveOrderOfCards()
    }
}
