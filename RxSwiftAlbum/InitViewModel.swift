//
//  InitViewModel.swift
//  RxSwiftAlbum
//
//  Created by RossSong on 2017. 5. 17..
//  Copyright © 2017년 RossSong. All rights reserved.
//

import Foundation
import RxSwift

class InitViewModel {
    init(flickrFeedsService:FlickrFeedsAPIService) {
        //FlickrFeeds 를 미리 받아 놓는다.
        flickrFeedsService.getFeeds()
    }
    
    func gotoPhotoViewController(sender:UIViewController) {
        let vc = sender.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        sender.present(vc, animated: true)
    }
    
}
