//
//  ViewController.swift
//  RxSwiftAlbum
//
//  Created by RossSong on 2017. 5. 16..
//  Copyright © 2017년 RossSong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InitViewController: UIViewController {

    @IBOutlet weak var buttonStart: UIButton!
    
    var initViewModel:InitViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initViewModel = InitViewModel(flickrFeedsService:FlickrFeedsAPIService.sharedInstance)
        self.buttonStart.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                print("buttonStart tapped")
                self.initViewModel.gotoPhotoViewController(sender:self)
        })
            .addDisposableTo(disposeBag)

    }
}

