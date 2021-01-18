//
//  RealmDB.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-18.
//

import Foundation
import RealmSwift
typealias CompletionHandler = (_ success:Bool) -> Void

//==========================================_DELETION WATERFALL_=============================================

//Season
func deleteSeason(season: Season, realm: Realm, completionHandler: CompletionHandler) {
    let entryPredicate = NSPredicate(format: "seasonId = %@", season._id)
    let entriesToDelete = realm.objects(HandbookEntry.self).filter(entryPredicate)

    deleteBunchEntrys(entriesToDelete: entriesToDelete, realm: realm, entryCompletionHandler: {(success) -> Void in
        if success{
            try! realm.write {
                realm.delete(season)
            }
            completionHandler(true)
        }
        else{
            completionHandler(false)
        }
    })
}

//Entry
func deleteEntry(entry: HandbookEntry, realm: Realm, completionHandler: CompletionHandler) {
    let blockPredicate = NSPredicate(format: "entryId = %@", entry._id)
    let blocksToDelete = realm.objects(Block.self).filter(blockPredicate)

    deleteBunchBlocks(blocksToDelete: blocksToDelete, realm: realm, blockCompletionHandler: {(success) -> Void in
        if success{
            try! realm.write {
                realm.delete(entry)
            }
            completionHandler(true)
        }
        else{
            completionHandler(false)
        }
    })
}

private func deleteBunchEntrys(entriesToDelete: Results<HandbookEntry>, realm: Realm, entryCompletionHandler: CompletionHandler){
    if(!entriesToDelete.isEmpty){
        for aEntry in entriesToDelete{
            let blockPredicate = NSPredicate(format: "entryId = %@", aEntry._id)
            let blocksToDelete = realm.objects(Block.self).filter(blockPredicate)

            deleteBunchBlocks(blocksToDelete: blocksToDelete, realm: realm, blockCompletionHandler: {(success) -> Void in
                if success{
                    try! realm.write {
                        realm.delete(aEntry)
                    }
                    entryCompletionHandler(true)
                }
                else{
                    entryCompletionHandler(false)
                }
            })
        }
    }
    //Collection Empty
    else{
        entryCompletionHandler(true)
    }

}

//Block
func deleteBlock(block: Block, realm: Realm, completionHandler: CompletionHandler) {
    let subBlockPredicate = NSPredicate(format: "blockId = %@", block._id)
    let subBlocksToDelete = realm.objects(SubBlock.self).filter(subBlockPredicate)

    deleteBunchSubBlocks(subBlocksToDelete: subBlocksToDelete, realm: realm, subBlockCompletionHandler: {(success) -> Void in
        if success{
            try! realm.write {
                realm.delete(block)
            }
            completionHandler(true)
        }
        else{
            completionHandler(false)
        }
    })
}

private func deleteBunchBlocks(blocksToDelete: Results<Block>, realm: Realm, blockCompletionHandler: CompletionHandler){
    if(!blocksToDelete.isEmpty){
        for aBlock in blocksToDelete{
            let subBlockPredicate = NSPredicate(format: "blockId = %@", aBlock._id)
            let subBlocksToDelete = realm.objects(SubBlock.self).filter(subBlockPredicate)

            deleteBunchSubBlocks(subBlocksToDelete: subBlocksToDelete, realm: realm, subBlockCompletionHandler: {(success) -> Void in
                if success{
                    try! realm.write {
                        realm.delete(aBlock)
                    }
                    blockCompletionHandler(true)
                }
                else{
                    blockCompletionHandler(false)
                }
            })
        }
    }
    else{
        blockCompletionHandler(true)
    }
}

//Block
func deleteSubBlock(subBlock: SubBlock, realm: Realm, completionHandler: CompletionHandler) {
    let cachesPredicate = NSPredicate(format: "subBlockId = %@", subBlock._id)
    let cachesToDelete = realm.objects(Cache.self).filter(cachesPredicate)

    deleteBunchCaches(cachesToDelete: cachesToDelete, realm: realm, cacheCompletionHandler: {(success) -> Void in
        if success{
            try! realm.write {
                realm.delete(subBlock)
            }
            completionHandler(true)
        }
        else{
            completionHandler(false)
        }
    })
}

private func deleteBunchSubBlocks(subBlocksToDelete: Results<SubBlock>, realm: Realm, subBlockCompletionHandler: CompletionHandler){
    if(!subBlocksToDelete.isEmpty){
        for aSubBlock in subBlocksToDelete{
            let cachePredicate = NSPredicate(format: "subBlockId = %@", aSubBlock._id)
            let cachesToDelete = realm.objects(Cache.self).filter(cachePredicate)

            deleteBunchCaches(cachesToDelete: cachesToDelete, realm: realm, cacheCompletionHandler: {(success) -> Void in
                if success{
                    try! realm.write {
                        realm.delete(aSubBlock)
                    }
                    subBlockCompletionHandler(true)
                }
                else{
                    subBlockCompletionHandler(false)
                }
            })
        }
    }
    //Collection Empty
    else{
        subBlockCompletionHandler(true)
    }
}

//Cache
func deleteCache(cache: Cache, realm: Realm, completionHandler: CompletionHandler) {
    try! realm.write {
        realm.delete(cache)
    }
    completionHandler(true)
}

private func deleteBunchCaches(cachesToDelete: Results<Cache>, realm: Realm, cacheCompletionHandler: CompletionHandler){
    try! realm.write {
        realm.delete(cachesToDelete)
    }
    cacheCompletionHandler(true)
}
