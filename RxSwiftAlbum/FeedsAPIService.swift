//
//  FeedsAPIService.swift
//  RxSwiftAlbum
//
//  Created by RossSong on 2017. 5. 17..
//  Copyright © 2017년 RossSong. All rights reserved.
//

import Foundation

protocol FeedsAPIService {
    func getFeeds();
    func countOfFeeds() -> Int;
    func getImageURL(_ index:Int) -> String?;
}
