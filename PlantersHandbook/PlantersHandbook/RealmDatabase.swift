//
//  RealmDatabase.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-25.
//

import Foundation
import RealmSwift
typealias CompletionHandler = (_ success:Bool) -> Void
typealias ErrorCompletionHandler = (_ success:Bool, _ error: String?) -> Void

/*
 This should only be used after the connectToRealm function has been called.
 It was needed to be initialized in a global scope but can only be connected once realm has been given from realm.Async.
 So the initializer is plain and struct is vulnerable to error before getting connected.
 Therefore no funcitons should be used until connect with Realm.async as shown in Login and Splash controllers. (It will result in a nil error)
 
 Reason for connecting Realm once for the whole applicaiton?
    - Conserves reopening realm for every function
    - MongoDB docs say to open a realm specificially for a view controller for security issues but with
      this note management application, Most view controller have the same realm, and passing the same realm from view controller to view controller is a waste of code from my perspective. There is no security issues once you open up the main realm in this application.
 */

///RealmDatabase.swift - All calls to store or manipulate user data in a realm
struct RealmDatabase{
    fileprivate var realm : Realm?
    fileprivate var partitionValue: String?
    
    ///Changes the realm
    ///- Parameter realm: Realm to be used for data extraction and manipulation
    public mutating func connectToRealm(realm: Realm){
        self.realm = realm
        self.partitionValue = "user=\(app.currentUser!.id)"
    }
    
    //===============FIND================
    
    ///Finds and returns the local user
    ///- Returns: Local user
    func findLocalUser() -> User?{
        let users = realm!.objects(User.self).filter(NSPredicate(format: "_id = %@", app.currentUser!.id))
        return users.first
    }
    
    ///Gives current partitiion value
    ///- Returns: Partition value
    func getParitionValue() -> String?{
        return partitionValue
    }

    ///Finds and returns subBlockss that are configured with the predicate
    ///- Parameter predicate: Filter for the realm
    ///- Returns: List in Results of subBlocks
    func findObjectRealm<T: Object>(predicate: NSPredicate?, classType: T) -> Results<T>{
        if let predicate = predicate{
            return realm!.objects(T.self).filter(predicate)
        }
        else{
            return realm!.objects(T.self)
        }
    }
    
    ///Finds and returns subBlock from id
    ///- Parameter subBlockId: Id of sublock
    ///- Returns: SubBlock if id is good, nil otherwise
    func findObjectById<T: Object>(Id: String, classType: T) -> T?{
        return realm!.objects(T.self).filter(NSPredicate(format: "_id = %@", Id)).first
    }
    
    //===============_ADD_================
 
    ///Adds a user to realm
    ///- Parameter user: User to be added
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func addUser(user: User, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite({
            realm!.add(user)
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Adds a season to realm
    ///- Parameter user: User to which season is to be added to
    ///- Parameter season: Season to be added to realm
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func addSeason(user: User, season: Season, completionHandler: ErrorCompletionHandler){
        let allSeasons = realm!.objects(Season.self)
        if allSeasons.contains(where: {$0.title == season.title}){
            completionHandler(false, "Duplicate Season Names")
        }
        else{
            if let error = realm!.safeWrite ({
                user.seasons.append(season._id)
                realm!.add(season)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    ///Adds a handbookEntry to realm
    ///- Parameter season: Season to which handbookEntry is to be added to
    ///- Parameter entry: HandbookEntry to be added
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func addEntry(season: Season, entry: HandbookEntry, completionHandler: ErrorCompletionHandler){
        let entryPredicate = NSPredicate(format: "_id IN %@", season.entries)
        let entries = realm!.objects(HandbookEntry.self).filter(entryPredicate)

        if entries.contains(where: {GeneralFunctions.getDate(from: $0.date) == GeneralFunctions.getDate(from: entry.date)}){
            completionHandler(false, "Duplicate Dates")
        }
        else{
            if let error = realm!.safeWrite ({
                season.entries.append(entry._id)
                realm!.add(entry)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    ///Adds a block to realm
    ///- Parameter entry: HandbookEntry to which block is to be added to
    ///- Parameter block: Block to be added
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func addBlock(entry: HandbookEntry, block: Block, completionHandler: ErrorCompletionHandler){
        let blockPredicate = NSPredicate(format: "_id IN %@", entry.blocks)
        let blocks = realm!.objects(Block.self).filter(blockPredicate)
        if blocks.contains(where: {$0.title == block.title}){
            completionHandler(false, "Duplicate Names")
        }
        else{
            if let error = realm!.safeWrite ({
                entry.blocks.append(block._id)
                realm!.add(block)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    ///Adds a subBlock to realm
    ///- Parameter block: Block to which subBlock is to be added to
    ///- Parameter subBlock: SubBlock to be added
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func addSubBlock(block: Block, subBlock: SubBlock, completionHandler: ErrorCompletionHandler){
        let subBlockPredicate = NSPredicate(format: "_id IN %@", block.subBlocks)
        let subBlocks = realm!.objects(SubBlock.self).filter(subBlockPredicate)
        if subBlocks.contains(where: {$0.title == subBlock.title}){
            completionHandler(false, "Duplicate Names")
        }
        else{
            if let error = realm!.safeWrite ({
                block.subBlocks.append(subBlock._id)
                realm!.add(subBlock)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    ///Adds a cache to realm
    ///- Parameter subBlock: SubBlock to which cache is to be added to
    ///- Parameter cache: Cache to be added
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func addCache(subBlock: SubBlock, cache: Cache, completionHandler: ErrorCompletionHandler){
        let cachePredicate = NSPredicate(format: "_id IN %@", subBlock.caches)
        let caches = realm!.objects(Cache.self).filter(cachePredicate)
        if caches.contains(where: {$0.title == cache.title}){
            completionHandler(false, "Duplicate Names")
        }
        else{
            if let error = realm!.safeWrite ({
                subBlock.caches.append(cache._id)
                realm!.add(cache)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    //===============_DELETION_================
    
    ///Delete a season from realm
    ///- Parameter season: Season to delete
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    func deleteSeason(season: Season, completionHandler: ErrorCompletionHandler) {
        let entryPredicate = NSPredicate(format: "_id IN %@", season.entries)
        let entriesToDelete = realm!.objects(HandbookEntry.self).filter(entryPredicate)
        let seasonId = String(season._id)
        
        if let user = findLocalUser(){
        if entriesToDelete.count == 0 {
            deletionAndListRemoval(deleteObject: season, superClassList: user.seasons, id: seasonId){ success, error in
                    completionHandler(success, error)
            }
        }else{
            let totalEntriesToDelete = entriesToDelete.count
            var totalEntriesDeleted = 0
            for entry in entriesToDelete{
                deleteEntry(entry: entry){ success, error in
                    if error == nil{
                        totalEntriesDeleted += 1
                        if(totalEntriesDeleted == totalEntriesToDelete){
                            deletionAndListRemoval(deleteObject: season, superClassList: user.seasons, id: seasonId){ success, error in
                                    completionHandler(success, error)
                            }
                        }
                    }else{
                        completionHandler(false, "Total Entries Deleted: \(totalEntriesDeleted) Total Entries Suppose to be deleted \(totalEntriesToDelete) Was not deleted \n Error: \(error!)")
                    }
                }
            }
        }
        }else{
            completionHandler(false, "User not found")
        }
    }
    
    ///Delete a handbookEntry from realm
    ///- Parameter entry: HandbookEntry to delete
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    func deleteEntry(entry: HandbookEntry, completionHandler: ErrorCompletionHandler) {
        let blockPredicate = NSPredicate(format: "_id IN %@", entry.blocks)
        let blocksToDelete = realm!.objects(Block.self).filter(blockPredicate)
        let entryId = String(entry._id)
        
        if let season = findObjectById(Id: entry.seasonId, classType: Season()){
        if blocksToDelete.count == 0 {
            deletionAndListRemoval(deleteObject: entry, superClassList: season.entries, id: entryId){ success, error in
                completionHandler(success, error)
            }
        }else{
            let totalBlocksToDelete = blocksToDelete.count
            var totalBlocksDeleted = 0
            for block in blocksToDelete{
                deleteBlock(block: block){ success, error in
                    if error == nil{
                        totalBlocksDeleted += 1
                        if(totalBlocksDeleted == totalBlocksToDelete){
                            deletionAndListRemoval(deleteObject: entry, superClassList: season.entries, id: entryId){ success, error in
                                completionHandler(success, error)
                            }
                        }
                    }else{
                        completionHandler(false, "Total Blocks Deleted: \(totalBlocksDeleted) Total Blocks Suppose to be deleted \(totalBlocksToDelete) Was not deleted \n Error: \(error!)")
                    }

                }
            }
            }
        }else{
            print("Entry Not Deleted, Season Not Found")
            completionHandler(false, "Season \(entry.seasonId)")
        }
    }

    ///Delete a block from realm
    ///- Parameter block: Block to delete
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    func deleteBlock(block: Block, completionHandler: ErrorCompletionHandler) {
        let subBlockPredicate = NSPredicate(format: "_id IN %@", block.subBlocks)
        let subBlocksToDelete = realm!.objects(SubBlock.self).filter(subBlockPredicate)
        let blockId = String(block._id)
        
        if let entry = findObjectById(Id: block.entryId, classType: HandbookEntry()){
        if subBlocksToDelete.count == 0 {
            deletionAndListRemoval(deleteObject: block, superClassList: entry.blocks, id: blockId){ success, error in
                completionHandler(success, error)
            }
        }else{
            let totalSubBlocksToDelete = subBlocksToDelete.count
            var totalSubBlocksDeleted = 0
            
                for subBlock in subBlocksToDelete{
                    deleteSubBlock(subBlock: subBlock){ success, error in
                        if error == nil{
                            totalSubBlocksDeleted += 1
                            if(totalSubBlocksDeleted == totalSubBlocksToDelete){
                                deletionAndListRemoval(deleteObject: block, superClassList: entry.blocks, id: blockId){ success, error in
                                    completionHandler(success, error)
                                }
                            }
                        }else{
                            completionHandler(false, "Total SubBlocks Deleted: \(totalSubBlocksDeleted) Total SubBlocks Suppose to be deleted \(totalSubBlocksToDelete) Was not deleted \n Error: \(error!)")
                        }
                    }
                    
                }
            }
        }else{
            print("HandbookEntry: \(block.entryId) Was Not Deleted")
            completionHandler(false, "HandbookEntry: \(block.entryId) Was Not Deleted")
        }
    }

    ///Delete a subBlock from realm
    ///- Parameter subBlock: SubBlock to delete
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    func deleteSubBlock(subBlock: SubBlock, completionHandler: ErrorCompletionHandler) {
        let cachePredicate = NSPredicate(format: "_id IN %@", subBlock.caches)
        let cachesToDelete = realm!.objects(Cache.self).filter(cachePredicate)
        let subBlockId = String(subBlock._id)
        
        if let block = findObjectById(Id: subBlock.blockId, classType: Block()){
            if cachesToDelete.count == 0 {
                deletionAndListRemoval(deleteObject: subBlock, superClassList: block.subBlocks, id: subBlockId){ success, error in
                    completionHandler(success, error)
                }
            }else{
                let totalCachesToDelete = cachesToDelete.count
                var totalCachesDeleted = 0
                for cache in cachesToDelete{
                    deleteCache(cache: cache){ success, error in
                        if error == nil{
                            totalCachesDeleted += 1
                            if(totalCachesDeleted == totalCachesToDelete){
                                deletionAndListRemoval(deleteObject: subBlock, superClassList: block.subBlocks, id: subBlockId){ success, error in
                                    completionHandler(success, error)
                                }
                            }
                        }else{
                            completionHandler(false, "Total Caches Deleted: \(totalCachesDeleted) Total Caches Suppose to be deleted \(totalCachesToDelete) Was not deleted \n Error: \(error!)")
                        }
                    }
                }
            }
        }else{
            print("Block: \(subBlock.blockId) Was Not Deleted")
            completionHandler(false, "Block: \(subBlock.blockId) Was Not Deleted")
        }
    }

    ///Delete a cache from realm
    ///- Parameter cache: Cache to delete
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    func deleteCache(cache: Cache, completionHandler: ErrorCompletionHandler) {
        print("Deleting Cache: \(cache._id)")
        if let subBlock = findObjectById(Id:  cache.subBlockId, classType: SubBlock()){
            let cacheId = String(cache._id)
            deletionAndListRemoval(deleteObject: cache, superClassList: subBlock.caches, id: cacheId){ success, error in
                completionHandler(success, error)
            }
        }else{
            completionHandler(false, "Could not find subblock " + cache.subBlockId)
        }
    }
    
    ///Delete object from realm and removes the id from list of the upper heirchy object
    ///- Parameter deleteObject: Object to delete
    ///- Parameter superClassList: List which contains object ID
    ///- Parameter itemInListToDelete: ID to delete
    func deletionAndListRemoval<T: Object>(deleteObject: T, superClassList: List<String>, id: String, completionHandler: ErrorCompletionHandler) {
        if let error = realm!.safeWrite ({
            print("\(deleteObject) Deleted")
            realm!.delete(deleteObject)
        }){
            completionHandler(false, error)
        }else{
            removeItemInList(list: superClassList, item: id){ success, error in
                print( (success ? "\(T.self) deleted from upperClass ID list" : "Item \(id) not found in \(superClassList) list"))
                completionHandler(success, error)
            }
        }
    }
    
    //===============UPDATE================
    
    ///Updates a user in realm
    ///- Parameter user: User to update in realm
    ///- Parameter _partition: Updated partition key used to identify what configuration the object belongs to
    ///- Parameter name: Updated name of user
    ///- Parameter company: Updated company of user
    ///- Parameter stepDistance: Updated step distance of user
    ///- Parameter seasons: Updated seasons user has
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateUser(user: User, _partition: String?, name: String?, company: String?, stepDistance: Int?, seasons: List<String>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            if let parition = _partition{
                user._partition = parition
            }
            if let name = name{
                user.name = name
            }
            if let company = company{
                user.company = company
            }
            if let stepDistance = stepDistance{
                user.stepDistance = stepDistance
            }
        }){
            completionHandler(false, error)
            return
        }else{
            if let seasons = seasons{
                updateList(list: user.seasons, newList: seasons){ _, error in
                    if error != nil{
                        completionHandler(false, error)
                    }
                }
            }
            completionHandler(true, nil)
        }
    }
    
    ///Updates a handbookEntry in realm
    ///- Parameter entry: HandbookEntry to update in realm
    ///- Parameter _partition: Updated partition key used to identify what configuration the object belongs to
    ///- Parameter seasonId: Updated seasonId of handbookEntry
    ///- Parameter notes: Updated notes of handbookEntry
    ///- Parameter date: Updated date of handbookEntry
    ///- Parameter blocks: Updated blocks handbookEntry has
    ///- Parameter extraCash: Updated extraCash that handbookEntry contains
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateHandbookEntry(entry: HandbookEntry, _partition: String?, seasonId: String?, notes: String?, date: Date?, blocks: List<String>?, extraCash: List<ExtraCash>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite({
            if let parition = _partition{
                entry._partition = parition
            }
            if let seasonId = seasonId{
                entry.seasonId = seasonId
            }
            if let notes = notes{
                entry.notes = notes
            }
            if let date = date{
                entry.date = date
            }
        }){
            completionHandler(false, error)
            return
        }else{
            if let blocks = blocks{
                updateList(list: entry.blocks, newList: blocks){ _, error in
                    if error != nil{
                        completionHandler(false, error)
                        return
                    }
                }
            }
            if let extraCash = extraCash{
                updateList(list: entry.extraCash, newList: extraCash){ _, error in
                    if error != nil{
                        completionHandler(false, error)
                        return
                    }
                }
            }
        }
    }
    
    ///Updates a ExtraCash in realm
    ///- Parameter extraCashList: ExtraCash list in handbookEntry
    ///- Parameter cash: Updated cash of ExtraCash
    ///- Parameter reason: Updated reason of ExtraCash
    ///- Parameter index: Index of where extra cash is in list inside
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateHandbookExtraCash(extraCashList: List<ExtraCash>, cash: Double?, reason: String?, index: Int, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            if let cash = cash{
                extraCashList[index].cash = cash
            }
            if let reason = reason{
                extraCashList[index].reason = reason
            }
        }){
            completionHandler(false, error)
        }
    }
    
    ///Updates a Block in realm
    ///- Parameter block: Block to update in realm
    ///- Parameter _partition: Updated partition key used to identify what configuration the object belongs to
    ///- Parameter entryId: Updated entryId of Block
    ///- Parameter title: Updated title of Block
    ///- Parameter date: Updated date of Block
    ///- Parameter subBlocks: Updated subBlocks Block has
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateBlock(block: Block, _partition: String?, entryId: String?, title: String?, date: Date?, subBlocks: List<String>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            if let parition = _partition{
                block._partition = parition
            }
            if let entryId = entryId{
                block.entryId = entryId
            }
            if let title = title{
                block.title = title
            }
            if let date = date{
                block.date = date
            }
        }){
            completionHandler(false, error)
        }else{
            if let subBlocks = subBlocks{
                updateList(list: block.subBlocks, newList: subBlocks){ _, error in
                    if error != nil{
                        completionHandler(false, error)
                        return
                    }
                }
            }
            
        }
    }
    
    ///Updates a SubBlock in realm
    ///- Parameter subBlock: SubBlock to update in realm
    ///- Parameter _partition: Updated partition key used to identify what configuration the object belongs to
    ///- Parameter blockId: Updated blockId of SubBlock
    ///- Parameter title: Updated title of SubBlock
    ///- Parameter date: Updated date of SubBlock
    ///- Parameter caches: Updated caches SubBlock has
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateSubBlock(subBlock: SubBlock, _partition: String?, blockId: String?, title: String?, date: Date?, caches: List<String>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite({
            if let parition = _partition{
                subBlock._partition = parition
            }
            if let blockId = blockId{
                subBlock.blockId = blockId
            }
            if let title = title{
                subBlock.title = title
            }
            if let date = date{
                subBlock.date = date
            }
        }){
            completionHandler(false, error)
            return
        }
        if let caches = caches{
            updateList(list: subBlock.caches, newList: caches){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
    }
    
    ///Updates a Cache in realm
    ///- Parameter cache: SubBlock to update in realm
    ///- Parameter _partition: Updated partition key used to identify what configuration the object belongs to
    ///- Parameter subBlockId: Updated blockId of SubBlock
    ///- Parameter title: Updated title of cache
    ///- Parameter isPlanting:Updated planting status
    ///- Parameter treePerPlot: Updated title of SubBlock
    ///- Parameter secondsPlanted: Updated date of SubBlock
    ///- Parameter treeTypes: Updated tree types
    ///- Parameter centPerTreeTypes: Updated cent per tree types
    ///- Parameter bundlesPerTreeTypes: Updated bundles per tree type
    ///- Parameter totalCashPerTreeTypes: Updated total cash per tree types
    ///- Parameter totalTreesPerTreeTypes: Updated total trees per tree types
    ///- Parameter bagUpsPerTreeTypes: Updated bag ups per tree types
    ///- Parameter plots: Updated plots in a cache
    ///- Parameter coordinatesCovered: Updated coordinates covered in gps
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateCache(cache: Cache, _partition: String?, subBlockId: String?, title: String?, isPlanting: Bool?, treePerPlot: Int?, secondsPlanted: List<Int>?, treeTypes: List<String>?, centPerTreeTypes: List<Double>?, bundlesPerTreeTypes: List<Int>?, totalCashPerTreeTypes: List<Double>?, totalTreesPerTreeTypes: List<Int>?, bagUpsPerTreeTypes: List<BagUpInput>?, plots: List<PlotInput>?, coordinatesCovered: List<CoordinateInput>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            if let parition = _partition{
                cache._partition = parition
            }
            if let subBlockId = subBlockId{
                cache.subBlockId = subBlockId
            }
            if let title = title{
                cache.title = title
            }
            if let isPlanting = isPlanting{
                cache.isPlanting = isPlanting
            }
            if let treePerPlot = treePerPlot{
                cache.treePerPlot = treePerPlot
            }
        }){
            completionHandler(false, error)
            return
        }else{
            completionHandler(true, nil)
        }
        if let secondsPlanted = secondsPlanted{
            updateList(list: cache.secondsPlanted, newList: secondsPlanted){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let treeTypes = treeTypes{
            updateList(list: cache.treeTypes, newList: treeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let centPerTreeTypes = centPerTreeTypes{
            updateList(list: cache.centPerTreeTypes, newList: centPerTreeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let bundlesPerTreeTypes = bundlesPerTreeTypes{
            updateList(list: cache.bundlesPerTreeTypes, newList: bundlesPerTreeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let totalCashPerTreeTypes = totalCashPerTreeTypes{
            updateList(list: cache.totalCashPerTreeTypes, newList: totalCashPerTreeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let treeTypes = treeTypes{
            updateList(list: cache.treeTypes, newList: treeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let bagUpsPerTreeTypes = bagUpsPerTreeTypes{
            for i in 0..<bagUpsPerTreeTypes.count{
                bagUpsPerTreeTypes[i].input.removeAll()
            }
            updateList(list: cache.bagUpsPerTreeTypes, newList: bagUpsPerTreeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let plots = plots{
            updateList(list: cache.plots, newList: plots){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let coordinatesCovered = coordinatesCovered{
            for i in 0..<coordinatesCovered.count{
                coordinatesCovered[i].input.removeAll()
            }
            updateList(list: cache.coordinatesCovered, newList: coordinatesCovered){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
    }
    
    //Quick Easy Commonly Used Update Functions for Cache
    
    ///Updates a Caches title in realm
    ///- Parameter cache: SubBlock to update in realm
    ///- Parameter title: Updated title of cache
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateCacheTitle(cache: Cache, title: String, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            cache.title = title
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Updates a Caches planting status in realm
    ///- Parameter cache: SubBlock to update in realm
    ///- Parameter isPlanting: Updated planting status
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateCacheIsPlanting(cache: Cache, bool: Bool, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            cache.isPlanting = bool
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Updates a Caches gps tree per plot number in realm
    ///- Parameter cache: SubBlock to update in realm
    ///- Parameter treesPerPlot: Updated gps rees per plot number
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateCacheTreePerPlot(cache: Cache, treesPerPlot: Int, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            cache.treePerPlot = treesPerPlot
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Updates a Caches plots in realm
    ///- Parameter cache: SubBlock to update in realm
    ///- Parameter plotArray: Updated gps rees per plot number
    ///- Parameter plotInputOne: Updated first plot input
    ///- Parameter plotInputTwo: Updated second plot input
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateCachePlotInputs(plotArray: List<PlotInput>, row: Int, plotInputOne: Int?, plotInputTwo: Int?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            if let inputOne = plotInputOne{
                plotArray[row].inputOne = inputOne
            }
            if let inputTwo = plotInputTwo{
                plotArray[row].inputTwo = inputTwo
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }

    //===============LIST================
    
    ///Adds object to a list in realm
    ///- Parameter list: Realm list to be manipulated
    ///- Parameter item: Object to be added
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func addToList<T>(list: List<T>, item: T, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.append(item)
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Updates list in realm with new list
    ///- Parameter list: Old Realm list
    ///- Parameter newList: New Realm list
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateList<T>(list: List<T>, newList: List<T>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
            for item in newList{
                list.append(item)
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Replace Item in list in realm
    ///- Parameter list: Realm list to be manipulated
    ///- Parameter index: Index of replacing item in list
    ///- Parameter item: Replacement Item
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func replaceItemInList<T>(list: List<T>, index: Int, item: T, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list[index] = item
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Updates list in realm with array
    ///- Parameter list: Old Realm list
    ///- Parameter copyArray: Array that contains elements to replace list
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func updateList<T>(list: List<T>, copyArray: [T], completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
            for item in copyArray{
                list.append(item)
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Clears all items in list safely
    ///- Parameter list: Realm list to be cleared
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func clearList<T>(list: List<T>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Removes last item in list safely
    ///- Parameter list: Realm list to be manipulated
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func removeLastInList<T>(list: List<T>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeLast()
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Removes item with index in list where safely
    ///- Parameter list: Realm list to be manipulated
    ///- Parameter index: Index of item to be removed from list
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func removeItemInList<T>(list: List<T>, index: Int, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.remove(at: index)
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Removes item in list safely
    ///- Parameter list: Realm list to be manipulated
    ///- Parameter item: Object supposedly list
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func removeItemInList<T>(list: List<T>, item: T, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            for i in 0..<list.count{
                if list[i] == item{
                    list.remove(at: i)
                    break
                }
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    //===============RANDOM================
    ///Clears tally sheet related attributes in cache
    ///- Parameter cache: Cache who needs to be cleared
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    public func clearCacheTally(cache: Cache, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            cache.treeTypes.removeAll()
            cache.treeTypes.append(objectsIn: CacheInitalValues.emptyStringList)
            cache.centPerTreeTypes.removeAll()
            cache.centPerTreeTypes.append(objectsIn: CacheInitalValues.emptyDoubleList)
            cache.bundlesPerTreeTypes.removeAll()
            cache.bundlesPerTreeTypes.append(objectsIn: CacheInitalValues.emptyIntList)
            cache.totalCashPerTreeTypes.removeAll()
            cache.totalCashPerTreeTypes.append(objectsIn: CacheInitalValues.emptyDoubleList)
            cache.totalTreesPerTreeTypes.removeAll()
            cache.totalTreesPerTreeTypes.append(objectsIn: CacheInitalValues.emptyIntList)
        }){
            completionHandler(false, error)
        }else{
            emptyTallyBagUps(list: cache.bagUpsPerTreeTypes){ success, error in
                if success{
                    emptyTallyPlots(list: cache.plots){ success, error in
                        if success{
                            completionHandler(true, nil)
                        }else{
                            completionHandler(false, error)
                        }
                    }
                }else{
                    completionHandler(false, error)
                }
            }
        }
    }
    
    ///Clears a realm list of primitives and replaces each index with a appending object
    ///- Parameter list: Realm list to be manipulated
    ///- Parameter appending: Replaces all objects in list
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    func emptyTallyPrimitiveList<T>(list: List<T>, appending: T, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
            for _ in 0..<TallyNumbers.columns{
                list.append(appending)
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Clears a realm list of BagUpInputs and replaces them with base value
    ///- Parameter list: Bag up list to be manipulated
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    func emptyTallyBagUps(list: List<BagUpInput>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
            for _ in 0..<TallyNumbers.bagUpRows{
                let bagUpInput = BagUpInput()
                bagUpInput.input.append(objectsIn: CacheInitalValues.emptyIntList)
                list.append(bagUpInput)
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }

    ///Clears a realm list of PlotInput and replaces them with base value
    ///- Parameter list: Plots list to be manipulated
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    func emptyTallyPlots(list: List<PlotInput>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
            for _ in 0..<TallyNumbers.bagUpRows{
                list.append(PlotInput())
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    ///Clears a realm list of CoodinateInput list
    ///- Parameter list: CoodinateInput list to be manipulated
    ///- Parameter completionHandler: Completion handler to tell function caller when done and if error occured
    func emptyCacheCoordinates(list: List<CoordinateInput>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            for coordinateList in list{
                coordinateList.input.removeAll()
            }
            list.removeAll()
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
}
