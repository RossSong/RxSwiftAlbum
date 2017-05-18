//
//  FlickFeedsAPIService.swift
//  RxSwiftAlbum
//
//  Created by RossSong on 2017. 5. 17..
//  Copyright © 2017년 RossSong. All rights reserved.
//

import Foundation
import RxSwift

class FlickrFeedsAPIService : NSObject, XMLParserDelegate, FeedsAPIService {
    static let sharedInstance = FlickrFeedsAPIService(NetworkManagerService.sharedInstance)
    
    fileprivate var manager : NetworkManager
    fileprivate var feeds = FlickrFeeds()
    
    init(_ networkManager:NetworkManager) {
        self.manager = networkManager
    }
    
    fileprivate struct Constants {
        static let baseURL = "https://api.flickr.com/services/feeds/photos_public.gne"
    }
    
    internal func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        print(elementName)
        print(attributeDict)
        
        self.feeds.append(elementName: elementName, attributeDict: attributeDict)
    }
    
    fileprivate func parseXML(xml :String) {
        let parser = XMLParser(data: xml.data(using: String.Encoding.utf8)!)
        parser.delegate = self
        parser.parse()
    }
    
    func getFeeds() {
        manager.getFeeds(Constants.baseURL) { xml in
            self.feeds.clear()
            self.parseXML(xml:xml)
        }
    }
    
    func countOfFeeds() -> Int {
        return feeds.count()
    }
    
    func getImageURL(_ index:Int) -> String? {
        return self.feeds.getImageURL(index)
    }
}
