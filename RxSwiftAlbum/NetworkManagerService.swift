//
//  NetworkManagerService.swift
//  RxSwiftAlbum
//
//  Created by RossSong on 2017. 5. 18..
//  Copyright © 2017년 RossSong. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import RxAlamofire
import RxSwift

class NetworkManagerService : NetworkManager {
    static let sharedInstance = NetworkManagerService()
    private let manager = SessionManager()
    
    func getFeeds(_ url:String, handler:@escaping (_ xml:String) -> ()) {
        let backgroundScheduler = SerialDispatchQueueScheduler(qos: .`default`)
        _ = manager.rx.responseString(.get, url)
            .observeOn(backgroundScheduler)
            .subscribe(onNext: { n in
                handler(n.1)
            })
    }
    
    func downloadImage (_ stringThumbnailURL:String, result:@escaping (_ image:UIImage) -> ()) {
        Alamofire.request(stringThumbnailURL).responseImage { response in
            debugPrint(response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                result(image)
            }
        }
    }
}
