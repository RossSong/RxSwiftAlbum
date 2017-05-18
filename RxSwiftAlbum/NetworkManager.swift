//
//  NetworkManager.swift
//  RxSwiftAlbum
//
//  Created by RossSong on 2017. 5. 18..
//  Copyright © 2017년 RossSong. All rights reserved.
//

import UIKit

protocol NetworkManager {
    func getFeeds(_ url:String, handler:@escaping (_ xml:String) -> ());
    func downloadImage (_ stringThumbnailURL:String, result:@escaping (_ image:UIImage) -> ());
}
