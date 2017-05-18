//
//  PhotoViewModel.swift
//  RxSwiftAlbum
//
//  Created by RossSong on 2017. 5. 17..
//  Copyright © 2017년 RossSong. All rights reserved.
//

import UIKit
import RxSwift

class PhotoViewModel : NSObject, XMLParserDelegate {
    var imageIndex:Int = 0
    
    var interval: Variable<String>
    var isLabelLoadingHidden : Variable<Bool>
    var currentImage : Variable<UIImage>
    let feedsService: FeedsAPIService
    let networkManager:NetworkManager
    
    var disposeBag:DisposeBag? = DisposeBag()
    
    init(feedsService: FeedsAPIService, networkManager:NetworkManager) {
        self.networkManager = networkManager
        self.feedsService = feedsService
        self.interval = Variable<String>("3")
        self.isLabelLoadingHidden = Variable<Bool>(false)
        self.currentImage = Variable<UIImage>(UIImage())
    }

    func updateImageViewAndGetMore(_ image:UIImage, result:@escaping (Void) -> Void = { _ in return }) {
        DispatchQueue.main.async {
            guard self.imageIndex < self.feedsService.countOfFeeds() else { return result()}
            self.isLabelLoadingHidden.value = true
            self.currentImage.value = image
            self.imageIndex = self.imageIndex + 1
            guard self.feedsService.countOfFeeds() - 2 < self.imageIndex else { return result() }
            self.imageIndex = 0
            self.feedsService.getFeeds()
            result()
        }
    }

    func downloadImage (_ stringThumbnailURL:String, result:@escaping (UIImage) -> Void = { _ in return }) {
        self.networkManager.downloadImage(stringThumbnailURL) { image in
            result(image)
        }
    }
    
    func updateCurrentImage(result:@escaping (String?) -> Void = { _ in return }){
        print("update")
        guard self.feedsService.countOfFeeds() > imageIndex else { return result(nil)}
        guard let imageURL = self.feedsService.getImageURL(imageIndex) else { return result(nil)}
        result(imageURL)
    }
    
    func startDownloadImage(result:@escaping (String?) -> Void = { _ in return }) {
        guard let timeInterVal = TimeInterval(self.interval.value) else { return }
        
        _ = Observable<Int>
            .interval(timeInterVal, scheduler: MainScheduler.instance)
            .subscribe({_ in
                self.updateCurrentImage(){ imageURL in
                    guard let url = imageURL else { return result("no imageURL")}
                    self.downloadImage(url) { image in
                        print("image downloaded")
                        print("image: \(image)")
                        self.updateImageViewAndGetMore(image)
                        result("completed")
                    }
                }
            })
        .addDisposableTo(disposeBag!)
    }

    fileprivate func checkFieldInterval() {
        if let val = Int32(self.interval.value) {
            if val > 10 {
                self.interval.value = "10";
            }
            else if val < 1 {
                self.interval.value = "1";
            }
            
            disposeBag = nil
            disposeBag = DisposeBag()
            startDownloadImage()
        }
    }

    func fieldIntervalChanged() {
        guard 0 < self.interval.value.characters.count else { return }
        checkFieldInterval()
    }
}
