//
//  FeedEntry.swift
//  RxSwiftAlbum
//
//  Created by RossSong on 2017. 5. 17..
//  Copyright © 2017년 RossSong. All rights reserved.
//

import Foundation

struct FlickrFeedEntry {
    let uriImage:String
    
    init?(_ attributeDict: [String : String]) {
        guard let uri = attributeDict["href"] else { return nil }
        uriImage = uri
    }
}

struct FlickrFeeds {
    var entries : [FlickrFeedEntry]
    
    init() {
        entries = [FlickrFeedEntry]()
    }
    
    func isTypeImageJPEG(_ type:String?) -> Bool {
        guard nil != type else { return false }
        
        if "image/jpeg" != type {
            return false
        }
        
        return true
    }
    
    mutating func addLinkHref(_ attributeDict:[String:String]) {
        if let entry = FlickrFeedEntry(attributeDict) {
            entries.append(entry)
        }
    }
    
    mutating func append(elementName:String, attributeDict:[String: String]) {
        guard "link" == elementName else { return }
        guard self.isTypeImageJPEG(attributeDict["type"]) else { return }
        self.addLinkHref(attributeDict)
    }
    
    mutating func clear() {
        entries = [FlickrFeedEntry]()
    }
    
    func count() -> Int {
        return entries.count
    }
    
    func getImageURL(_ index:Int) -> String? {
        guard index < self.entries.count else { return nil }
        return self.entries[index].uriImage
    }
}
