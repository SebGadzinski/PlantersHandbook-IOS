//
//  PlantersHandbookTests.swift
//  PlantersHandbookTests
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import XCTest
@testable import PlantersHandbook
import RealmSwift

class PlantersHandbookTests: XCTestCase {
    
    ///Tests if the database can add and delete a Season, HandbookEntry, Block, SubBlock, and a Cache
    func testRealmDatabaseBasic(){
        startTestFunction(testName: "testRealmDatabaseBasic"){ result in
            XCTAssertTrue(result)
            if(result){
                self.realmDatabaseAddBasic(){ result in
                    XCTAssertTrue(result)
                    if(result){
                        self.realmDatabaseDeleteBasic(){ result in
                            XCTAssertTrue(result)
                            if result{
                                self.printFromTest(message: "Cleared testRealmDatabaseBasic")
                            }else{
                                self.printFromTest(message: "Failed testRealmDatabaseBasic")
                            }
                        }
                    }else{
                        self.printFromTest(message: "Failed testRealmDatabaseBasic")
                    }
                }
            }else{
                self.printFromTest(message: "Failed testRealmDatabaseBasic")
            }
        }
    }

    ///Tests deleting a season, and makes sure all the classes below attached to season get deleted
    func testRealmDatabaseDeletionWaterfall(){
        startTestFunction(testName: "testRealmDatabaseDeletionWaterfall"){ result in
            XCTAssertTrue(result)
            if(result){
                self.realmDatabaseAddBasic(){ result in
                    XCTAssertTrue(result)
                    if(result){
                        self.realmDatabaseClearTestUser(){ result in
                            XCTAssertTrue(result)
                            if result{
                                self.printFromTest(message: "Cleared testRealmDatabaseDeletionWaterfall")
                            }else{
                                self.printFromTest(message: "Failed testRealmDatabaseDeletionWaterfall")
                            }
                        }
                    }else{
                        self.printFromTest(message: "Failed testRealmDatabaseDeletionWaterfall")
                    }
                }
            }else{
                self.printFromTest(message: "Failed testRealmDatabaseDeletionWaterfall")
            }
        }
    }
    
    ///Tests the creation of a full test user with 2 seasons
    func testCreationOfFullTestUser(){
        startTestFunction(testName: "testCreationOfFullTestUser"){ result in
            XCTAssertTrue(result)
            if(result){
                self.filltestUserWithSeasons(numberOfSeasons: 2){ result in
                    XCTAssertTrue(result)
                    if result{
                        self.printFromTest(message: "Cleared testCreationOfFullTestUser")
                    }else{
                        self.printFromTest(message: "Failed testCreationOfFullTestUser")
                    }
                }
            }else{
                self.printFromTest(message: "Failed test")
            }
        }
    }
    
    //Skeleton of a test case
//    func test(){
//        printFromTest(message: "test")
//
//        startTestFunction(testName: "test"){ result in
//            XCTAssertTrue(result)
//            if(result){
//
//            }else{
//                self.printFromTest(message: "Failed test")
//            }
//        }
//    }
    
    // ==== Test Case Helper Functions ====
    
    ///This function is to be called before any test, it logs into test user and deletes all data inside
    ///- Parameter testName: Tests name that will be running
    ///- Parameter completion: Completion handler to be called when  function completed
    func startTestFunction(testName: String, completion: @escaping (CompletionHandler)){
        printFromTest(message: "Started " + testName)
        loginTestUser(){ result in
            XCTAssertTrue(result)
            if(result){
                XCTAssertTrue(result)
                if(result){
                    self.realmDatabaseClearTestUser(){ result in
                        XCTAssertTrue(result)
                        if result{
                            completion(true)
                        }else{
                            completion(false)
                        }
                    }
                }else{
                    completion(false)
                }
            }else{
                completion(false)
            }
        }
    }
    
    ///Logs in test user
    ///- Parameter completion: Completion handler to be called when function completed
    func loginTestUser(completion: @escaping (CompletionHandler)){
        printFromFunction(message: "Started loginTestUser")
        
        let expectation = self.expectation(description: "Login")
        var bool = false
        app.login(credentials: Credentials.emailPassword(email: "testPlantersHandbook@gmail.com", password: "TestApp123!")) { (result) in
            switch result {
            case .failure(let error):
                // Auth error: user already exists? Try logging in as that user.
                print("Login failed: \(error)");
                return
            case .success(let user):
                var configuration = user.configuration(partitionValue: "user=\(user.id)", cancelAsyncOpenOnNonFatalErrors: true)

                configuration.objectTypes = [User.self, Season.self, HandbookEntry.self, Block.self, SubBlock.self, Cache.self, BagUpInput.self, PlotInput.self, CoordinateInput.self, Coordinate.self, ExtraCash.self]

                Realm.asyncOpen(configuration: configuration) { (result) in
                    switch result {
                        case .failure(let error):
                            expectation.fulfill()
                            fatalError("Failed to open realm: \(error)")
                        case .success(let realm):
                            bool = true
                            realmDatabase.connectToRealm(realm: realm)
                            XCTAssert(true, "User Logged In")
                            expectation.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 10, handler: {_ in
            if(bool){
                self.printFromFunction(message: "Cleared loginTestUser")
            }else{
                self.printFromFunction(message: "Failed loginTestUser")
            }
            completion(bool)
        })
    }

    ///Adds a Season, HandbookEntry, Block, SubBlock, and a Cache to test user
    ///- Parameter completion: Completion handler to be called when function completed
    func realmDatabaseAddBasic(completion: @escaping (CompletionHandler)){
        printFromFunction(message: "Started realmDatabaseAddBasic")
        let expectation = self.expectation(description: "Add Basic Realm")
        var bool = false
        
        let season =  Season(partition: realmDatabase.getParitionValue()!, title: "Season")
        if let user = realmDatabase.findLocalUser(){
            realmDatabase.addSeason(user: user, season: season){ success, error in
                if error == nil{
                    XCTAssertEqual(realmDatabase.findObjectById(Id: season._id, classType: Season()), season)
                    let entry = HandbookEntry(partition: realmDatabase.getParitionValue()!, seasonId: season._id)
                    realmDatabase.addEntry(season: season, entry: entry){ success, error in
                        if error == nil{
                            XCTAssertEqual(realmDatabase.findObjectById(Id: entry._id, classType: HandbookEntry()), entry)
                            let block = Block(partition: realmDatabase.getParitionValue()!, title: "Block", entryId: entry._id)
                            realmDatabase.addBlock(entry: entry, block: block){success, error in
                                if error == nil{
                                    XCTAssertEqual(realmDatabase.findObjectById(Id: block._id, classType: Block()), block)
                                    let subBlock = SubBlock(partition: realmDatabase.getParitionValue()!, title: "SubBlock", blockId: block._id)
                                    realmDatabase.addSubBlock(block: block, subBlock: subBlock){success, error in
                                        if error == nil{
                                            XCTAssertEqual(realmDatabase.findObjectById(Id: subBlock._id, classType: SubBlock()), subBlock)
                                            let cache = Cache(partition: realmDatabase.getParitionValue()!, title: "Cache", subBlockId: subBlock._id)
                                            realmDatabase.addCache(subBlock: subBlock, cache: cache){success, error in
                                                if error == nil{
                                                    XCTAssertEqual(realmDatabase.findObjectById(Id: cache._id, classType: Cache()), cache)
                                                    bool = true
                                                    expectation.fulfill()
                                                }else{
                                                    XCTAssert(success, error!)
                                                    expectation.fulfill()
                                                }
                                            }
                                        }else{
                                            XCTAssert(success, error!)
                                            expectation.fulfill()
                                        }
                                    }
                                }else{
                                    XCTAssert(success, error!)
                                    expectation.fulfill()
                                }
                            }
                        }else{
                            XCTAssert(success, error!)
                            expectation.fulfill()
                        }
                    }
                }else{
                    XCTAssert(success, error!)
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 5, handler: {_ in
            if(bool){
                self.printFromFunction(message: "Cleared realmDatabaseAddBasic")
            }else{
                self.printFromFunction(message: "Failed realmDatabaseAddBasic")
            }
            completion(bool)
        })
    }

    ///Deletes a Cache, SubBlock, Block, HandbookEntry, and a Season from test user
    ///- Parameter completion: Completion handler to be called when function completed
    func realmDatabaseDeleteBasic(completion: @escaping (CompletionHandler)){
        printFromFunction(message: "Started realmDatabaseDeleteBasic")
        let expectation = self.expectation(description: "Delete Basic Realm")
        var bool = false
        
        let cache = realmDatabase.findObjectRealm(predicate: nil, classType: Cache()).first!
        realmDatabase.deleteCache(cache: cache){ success, error in
            if error == nil{
                XCTAssertTrue(cache.isInvalidated)
                let subBlock = realmDatabase.findObjectRealm(predicate: nil, classType: SubBlock()).first!
                XCTAssertTrue(subBlock.caches.isEmpty)
                realmDatabase.deleteSubBlock(subBlock: subBlock){ success, error in
                    if error == nil{
                        XCTAssertTrue(subBlock.isInvalidated)
                        let block = realmDatabase.findObjectRealm(predicate: nil, classType: Block()).first!
                        XCTAssertTrue(block.subBlocks.isEmpty)
                        realmDatabase.deleteBlock(block: block){ success, error in
                            if error == nil{
                                XCTAssertTrue(block.isInvalidated)
                                let entry = realmDatabase.findObjectRealm(predicate: nil, classType: HandbookEntry()).first!
                                XCTAssertTrue(entry.blocks.isEmpty)
                                realmDatabase.deleteEntry(entry: entry){ success, error in
                                    if error == nil{
                                        XCTAssertTrue(entry.isInvalidated)
                                        let season = realmDatabase.findObjectRealm(predicate: nil, classType: Season()).first!
                                        XCTAssertTrue(season.entries.isEmpty)
                                        realmDatabase.deleteSeason(season: season){ success, error in
                                            if error == nil{
                                                XCTAssertTrue(season.isInvalidated)
                                                bool = true
                                                expectation.fulfill()
                                            }else{
                                                XCTAssert(success, error!)
                                                expectation.fulfill()
                                            }
                                        }
                                    }else{
                                        XCTAssert(success, error!)
                                        expectation.fulfill()
                                    }
                                }
                            }else{
                                XCTAssert(success, error!)
                                expectation.fulfill()
                            }
                        }
                    }else{
                        XCTAssert(success, error!)
                        expectation.fulfill()
                    }
                }
            }else{
                XCTAssert(success, error!)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: {_ in
            if(bool){
                self.printFromFunction(message: "Cleared realmDatabaseDeleteBasic")
            }else{
                self.printFromFunction(message: "Failed realmDatabaseDeleteBasic")
            }
            completion(bool)
        })
    }

    ///Deletes all information in test user
    ///- Parameter completion: Completion handler to be called when function completed
    func realmDatabaseClearTestUser(completion: @escaping (CompletionHandler)){
        printFromFunction(message: "Started realmDatabaseClearTestUser")
        let expectation = self.expectation(description: "Delete Basic Realm")
        var bool = false
        var deletedCount = 0
        let seasons = realmDatabase.findObjectRealm(predicate: nil, classType: Season())
        let totalToDelete = seasons.count
        
        if(totalToDelete == 0){
            bool = true
            expectation.fulfill()
        }
        
        for season in seasons{
            realmDatabase.deleteSeason(season: season){ success, error in
                if error == nil{
                    deletedCount += 1
                    if(deletedCount == totalToDelete){
                        XCTAssertTrue(realmDatabase.findObjectRealm(predicate: nil, classType: Season()).isEmpty)
                        XCTAssertTrue(realmDatabase.findObjectRealm(predicate: nil, classType: HandbookEntry()).isEmpty)
                        XCTAssertTrue(realmDatabase.findObjectRealm(predicate: nil, classType: Block()).isEmpty)
                        XCTAssertTrue(realmDatabase.findObjectRealm(predicate: nil, classType: SubBlock()).isEmpty)
                        XCTAssertTrue(realmDatabase.findObjectRealm(predicate: nil, classType: Cache()).isEmpty)
                        bool = true
                        expectation.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 5, handler: {_ in
            if(bool){
                self.printFromFunction(message: "Cleared realmDatabaseClearTestUser")
            }else{
                self.printFromFunction(message: "Failed realmDatabaseClearTestUser")
            }
            completion(bool)
        })
    }
    
    ///Deletes all information in test user and creates a user with x amount of seasons
    ///- Parameter numberOfSeasons: Number of seasons to fill test user with
    ///- Parameter completion: Completion handler to be called when function completed
    func filltestUserWithSeasons(numberOfSeasons: Int, completion: @escaping (CompletionHandler)){
        let expectation = self.expectation(description: "Fill User With Seasons")
        var bool = false
        let numberOfHandbookEntries = 60
        let multipleBlockPercentageNumber = 6
        let multipleSubBlockPercentageNumber = 8
        let multipleCachePercentageNumber = 10
        let multipleTreeTypesPercentageNumber = 30
        let currentYear = Calendar.current.component(.year, from: Date())
        
        if let user = realmDatabase.findLocalUser(){
            for seasonNumber in 0..<numberOfSeasons{
                let listOfDates = seasonDates(year: currentYear - (numberOfSeasons - seasonNumber), numberOfDates: numberOfHandbookEntries)
                
                let season = Season(partition: realmDatabase.getParitionValue()!, title: "Season " + "\(seasonNumber + 1)")
                print("\nCreating \(season.title)\n")

                realmDatabase.addSeason(user: user, season: season){ success, error in
                    if success{
                        for handbookEntryNumber in 0..<numberOfHandbookEntries{
                            let handbookEntry = HandbookEntry(partition: realmDatabase.getParitionValue()!, seasonId: season._id, date: listOfDates[handbookEntryNumber])
                            assignRandomExtraCash(extraCashList: handbookEntry.extraCash)
                            realmDatabase.addEntry(season: season, entry: handbookEntry){ success, error in
                                var blocks : [Block] = []
                                var subBlocks : [SubBlock] = []
                                var caches : [Cache] = []
                                
                                if error == nil{
                                    let totalCashHandbookEntry = Double.random(in: 200..<600).round(to: 2)
                                    let totalSecondsPlantedEntry = 30000 + Int.random(in: 1..<10000)
                                    var currentCashHandbookEntry = 0.0
                                    let numberOfBlocks = 1 + numberOfTimes(percentageOfPassing: multipleBlockPercentageNumber)
                                    for blockNumber in 0..<numberOfBlocks{
                                        let block = Block(partition: realmDatabase.getParitionValue()!, title: "Block " + String(blockNumber + 1), entryId: handbookEntry._id)
                                        blocks.append(block)
                                        var totalCashBlock = 0.0
                                        var currentCashBlock = 0.0
                                        
                                        if(numberOfBlocks - 1 == blockNumber){
                                            totalCashBlock = (totalCashHandbookEntry - currentCashHandbookEntry).round(to: 2)
                                            currentCashHandbookEntry = totalCashHandbookEntry
                                        }else{
                                            let cashToAdd = Double.random(in: 0..<totalCashHandbookEntry - currentCashHandbookEntry).round(to: 2)
                                            totalCashBlock = cashToAdd
                                            currentCashHandbookEntry += cashToAdd
                                        }
                                        
                                        let numberOfSubBlocks = 1 + numberOfTimes(percentageOfPassing: multipleSubBlockPercentageNumber)
                                        for subBlockNumber in 0..<numberOfSubBlocks{
                                            let subBlock = SubBlock(partition: realmDatabase.getParitionValue()!, title: "SubBlock " + String(subBlockNumber + 1), blockId: block._id)
                                            subBlocks.append(subBlock)
                                                var totalCashSubBlock = 0.0
                                                var currentCashSubBlock = 0.0
                                                
                                                if(numberOfSubBlocks - 1 == subBlockNumber){
                                                    totalCashSubBlock = (totalCashBlock - currentCashBlock).round(to: 2)
                                                    currentCashBlock = totalCashBlock
                                                }else{
                                                    let cashToAdd = Double.random(in: 0..<totalCashBlock - currentCashBlock).round(to: 2)
                                                    totalCashSubBlock = cashToAdd
                                                    currentCashBlock += cashToAdd
                                                }
                                                
                                                let numberOfCaches = 1 + numberOfTimes(percentageOfPassing: multipleCachePercentageNumber)
                                                for cacheNumber in 0..<numberOfCaches{
                                                    var totalCashCache = 0.0
                                                    
                                                    if(numberOfCaches - 1 == cacheNumber){
                                                        totalCashCache = (totalCashSubBlock - currentCashSubBlock).round(to: 2)
                                                        currentCashSubBlock = totalCashSubBlock
                                                    }else{
                                                        let cashToAdd = Double.random(in: 0..<totalCashSubBlock - currentCashSubBlock).round(to: 2)
                                                        totalCashCache = cashToAdd
                                                        currentCashSubBlock += cashToAdd
                                                    }
                                                    let numberOfTreeTypes = 1 + numberOfTimes(percentageOfPassing: multipleTreeTypesPercentageNumber)
                                                    let treeTypesSelected = selectTreeTypes(numberOfTreeTypes: numberOfTreeTypes)
                                                    let treeTypes = List<String>()
                                                    let centPerTreeTypes = List<Double>()
                                                    let bundleAmountPerTreeTypes = List<Int>()
                                                    treeTypes.append(objectsIn: CacheInitalValues.emptyStringList)
                                                    centPerTreeTypes.append(objectsIn: CacheInitalValues.emptyDoubleList)
                                                    bundleAmountPerTreeTypes.append(objectsIn: CacheInitalValues.emptyIntList)
                                                    for i in 0..<numberOfTreeTypes{
                                                        treeTypes[i] = treeTypesSelected[i].type
                                                        centPerTreeTypes[i] = treeTypesSelected[i].cents
                                                        bundleAmountPerTreeTypes[i] = treeTypesSelected[i].bundleAmount
                                                    }
                                                    let numberOfBagUps = Int.random(in: 8..<12)
                                                    let (bagUpLists, totalTreesList, totalCashList) = createRandomBagUpsAndTotals(numberOfTreeTypes: numberOfTreeTypes, totalCashCache: totalCashCache, treeTypes: treeTypesSelected, numberOfBagUps: numberOfBagUps)
                                                    //Sometimes there is no trees inside (HIGHLY UNLIKELY, LITERALLY 0.001% - cash needs to be extreamly low
                                                    let plotsList = createRandomPlotsList(numberOfPlots: (totalTreesList[0] > 1 ? numberOfBagUps : 0))
                                                    let coordinateInput = CoordinateInput()
                                                    coordinateInput.input.append(objectsIn: createFalseCoordinates(type: Int.random(in: 0..<3)))
                                                    let coordinatesCovered = List<CoordinateInput>()
                                                    coordinatesCovered.append(coordinateInput)
                                                    let secondsPlanted = List<Int>()
                                                    secondsPlanted.append(totalSecondsPlantedEntry/(numberOfSubBlocks*numberOfBlocks))
                                                    let cache = Cache(partition: realmDatabase.getParitionValue()!, title: "Cache " + String(cacheNumber + 1), subBlockId: subBlock._id, treeTypes: treeTypes, centPerTreeTypes: centPerTreeTypes, bundlesPerTreeTypes: bundleAmountPerTreeTypes, bagUpsPerTreeTypes: bagUpLists, plots: plotsList, totalCashPerTreeTypes: totalCashList, totalTreesPerTreeTypes: totalTreesList, secondsPlanted: secondsPlanted, coordinatesCovered: coordinatesCovered)
                                                    caches.append(cache)
                                                }
                                            }
                                        }
                                }
                            for i in 0..<blocks.count{
                                realmDatabase.addBlock(entry: handbookEntry, block: blocks[i]){success, error in
                                    if success{
                                        if(i == blocks.count - 1){
                                            for y in 0..<subBlocks.count{
                                                let subBlockBlock = blocks.first(where: {$0._id == subBlocks[y].blockId})
                                                realmDatabase.addSubBlock(block: subBlockBlock!, subBlock: subBlocks[y]){ success, error in
                                                    if success{
                                                        if(y == subBlocks.count - 1){
                                                            for x in 0..<caches.count{
                                                                let cacheSubBlock = subBlocks.first(where: {$0._id == caches[x].subBlockId})
                                                                realmDatabase.addCache(subBlock: cacheSubBlock!, cache: caches[x]){success, error in
                                                                    if success{
                                                                        if seasonNumber == numberOfSeasons - 1 && handbookEntryNumber == numberOfHandbookEntries - 1 && x == caches.count - 1{
                                                                            bool = true
                                                                            expectation.fulfill()
                                                                        }
                                                                        print("HandbookEntry Created: " + GeneralFunctions.getDate(from: handbookEntry.date))
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        waitForExpectations(timeout: 20, handler: {_ in
            if(bool){
                self.printFromFunction(message: "Cleared filltestUserWithSeasons")
            }else{
                self.printFromFunction(message: "Failed filltestUserWithSeasons")
            }
            completion(bool)
        })
    }
    
    ///Gives a list of dates from May 1st (When Planting Season Starts) at a given year and creates x dates from that time, skipping every 3rd day
    ///- Parameter year: Year of when planting season starts
    ///- Parameter numberOfDates: Number of entries this season
    ///- Returns: Number of times percentage hit
    func seasonDates(year: Int, numberOfDates: Int) -> [Date]{
        var listOfDates : [Date] = []
        let todaysDate = Date(dateString: "\(year)-5-1")
        var breakDays = 0
        
        for dateNumber in 0..<numberOfDates{
            if(dateNumber % 3 == 0 && dateNumber != 0){
                breakDays += 1
            }
            listOfDates.append(Calendar.current.date(byAdding: .day, value: dateNumber + breakDays, to: todaysDate)!)
        }
        
        return listOfDates
    }
    
    ///Fills extra cash list with random Extra Cashes
    ///- Parameter extraCashList: ExtraCash list to be filled
    func assignRandomExtraCash(extraCashList: List<ExtraCash>){
        while true{
            if Int.random(in: 1..<100) < 7{
                realmDatabase.addToList(list: extraCashList, item: ExtraCash(value: ["cash":Float(Int.random(in: 1..<50)), "reason": "a reason"])){ success, error in
                    if !success{
                        print(error!)
                    }
                }
            }else{
                break
            }
        }
    }
    
    func createFalseCoordinates(type : Int) -> [Coordinate]{
        if(type > 2 || type < 0) {return []}
        
        let fillsToChooseFrom : [(startBottomCoordinate: Coordinate, startTopCoordinate: Coordinate, endLongitude: Double)] = [
            (Coordinate(longitude: -118.46599792858562, latitude:  56.11347158705347), Coordinate(longitude: -118.46597848257026, latitude: 56.12128852565642), -118.45760403929255),
            (Coordinate(longitude: -118.39163343219063, latitude:  56.101819002255795), Coordinate(longitude: -118.39160325733921, latitude: 56.10892040622178), -118.37929728237889),
            (Coordinate(longitude: -118.28727840242884, latitude:  56.09128938325521), Coordinate(longitude: -118.28702225146792, latitude: 56.10130234601308), -118.27476153878472)
        ]
        
        var incrementInLongitude = 0.0
        var listOfCoordinates : [Coordinate] = []
        
        listOfCoordinates.append(fillsToChooseFrom[type].startBottomCoordinate)
        
        var count = 0
        while true{
            listOfCoordinates.append(Coordinate(longitude: (count % 2 == 0 ? fillsToChooseFrom[type].startTopCoordinate.longitude : fillsToChooseFrom[type].startBottomCoordinate.longitude) + (incrementInLongitude), latitude: (count % 2 == 0 ? fillsToChooseFrom[type].startTopCoordinate.latitude : fillsToChooseFrom[type].startBottomCoordinate.latitude)))
            incrementInLongitude += 0.0007
            listOfCoordinates.append(Coordinate(longitude: (count % 2 == 0 ? fillsToChooseFrom[type].startTopCoordinate.longitude : fillsToChooseFrom[type].startBottomCoordinate.longitude) + (incrementInLongitude), latitude: (count % 2 == 0 ? fillsToChooseFrom[type].startTopCoordinate.latitude : fillsToChooseFrom[type].startBottomCoordinate.latitude)))
            if fillsToChooseFrom[type].endLongitude < listOfCoordinates.last!.longitude{
                break
            }
            count += 1
        }
        
        return listOfCoordinates
    }
    
    ///Given a percentage, this function gives back number of times this percentage passed
    ///- Parameter percentageOfPassing: Percntage of passsing
    ///- Returns: Number of times percentage hit
    func numberOfTimes(percentageOfPassing: Int) -> Int{
        var number = 0
        while true{
            if Int.random(in: 1..<100) < percentageOfPassing{
                number += 1
            }else{
                break
            }
        }
        return number
    }
    
    ///Selects random treeTypes from a fixed list of treeTypes
    ///- Parameter numberOfTreeTypes: Number of treetypes that will need bag up info on
    ///- Returns: Tree types consisting of type, cent per tree type, and bundle amount per tree type
    func selectTreeTypes(numberOfTreeTypes: Int) -> [(type: String, cents: Double, bundleAmount: Int)]{
        let typesOfTreesToChooseFrom : [(type: String, cents: Double, bundleAmount: Int)] = [
            ("PL-145", 0.14, 20),
            ("SX-134", 0.15, 15),
            ("SX-345", 0.14, 15),
            ("FUR-123", 0.16, 20),
            ("PL-165", 0.15, 15),
            ("PL-342", 0.13, 20)
        ]
        var listOfTreeTypes : [(type: String, cents: Double, bundleAmount: Int)] = []
        
        while listOfTreeTypes.count != numberOfTreeTypes{
            let randomSelection = typesOfTreesToChooseFrom[Int.random(in: 0..<typesOfTreesToChooseFrom.count)]
            if !listOfTreeTypes.contains(where: {$0 == randomSelection}){
                listOfTreeTypes.append(randomSelection)
            }
        }
            
        return listOfTreeTypes
    }
    
    ///Creates Random BagUpPerTreeTypes List, TotalCashPerTreetypes, and TotalTreesPerTreeTypes Lists
    ///- Parameter numberOfTreeTypes: Number of treetypes that will need bag up info on
    ///- Parameter totalCashCache: Total cash that the bag ups can go to
    ///- Parameter treeTypes: Tree types consisting of type, cent per tree type, and bundle amount per tree type
    ///- Parameter numberOfBagUps: Number of bag ups allowed for each tree type
    ///- Returns: BagUpPerTreeTypes List, TotalCashPerTreetypes, and TotalTreesPerTreeTypes Lists
    func createRandomBagUpsAndTotals(numberOfTreeTypes: Int, totalCashCache: Double, treeTypes: [(type: String, cents: Double, bundleAmount: Int)], numberOfBagUps: Int) -> (List<BagUpInput>, List<Int>, List<Double>){
        let bagUpList = List<BagUpInput>()
        let totalTreesList = List<Int>()
        let totalCashList = List<Double>()
        
        let treeTypeCash = (totalCashCache/Double(numberOfTreeTypes)).round(to: 2)
        
        for _ in 0..<TallyNumbers.bagUpRows{
            let bagUpInput = BagUpInput()
            bagUpInput.input.append(objectsIn: CacheInitalValues.emptyIntList)
            bagUpList.append(bagUpInput)
        }
        
        for i in 0..<TallyNumbers.columns{
            if numberOfTreeTypes > i{
                let amountOfTrees = Int((treeTypeCash / treeTypes[i].cents).rounded(.towardZero))
                let treesInSingleBagUp = Int((amountOfTrees/numberOfBagUps)).rounding(nearest: Float(treeTypes[i].bundleAmount))
                for y in 0..<TallyNumbers.bagUpRows{
                    if numberOfBagUps > y{
                        bagUpList[y].input[i] = treesInSingleBagUp
                    }else{
                        break
                    }
                }
                totalCashList.append(Double(treesInSingleBagUp*numberOfBagUps)*treeTypes[i].cents)
                totalTreesList.append(treesInSingleBagUp*numberOfBagUps)
            }else{
                totalCashList.append(0.0)
                totalTreesList.append(0)
            }
        }
        return (bagUpList, totalTreesList, totalCashList)
    }
    
    ///Creates and fills List<PlotInput> randomly
    ///- Parameter numberOfPlots: Number of plots to populate
    ///- Returns: Populated list of plots
    func createRandomPlotsList(numberOfPlots: Int) -> List<PlotInput>{
        let plotsList = List<PlotInput>()
        let plotDensity = Int.random(in: 2..<15)
        for i in 0..<TallyNumbers.bagUpRows{
            let plotInput = PlotInput()
            if numberOfPlots > i{
                plotInput.inputOne = plotDensity + (Int.random(in: 0..<2))
                plotInput.inputTwo = plotDensity + (Int.random(in: 0..<2))
            }
            plotsList.append(plotInput)
        }
        return plotsList
    }

    ///Prints from a function should call this method to print to terminal
    ///- Parameter message: Message to print
    func printFromFunction(message: String){
        print("- \(message)")
    }
    
    ///Prints from a test case should call this method to print to terminal
    ///- Parameter message: Message to print
    func printFromTest(message: String){
        print("\n\n *** \(message) *** \n\n")
    }
    
    
}
