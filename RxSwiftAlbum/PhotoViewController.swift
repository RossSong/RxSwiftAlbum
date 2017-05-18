//
//  PhotoViewController.swift
//  RxSwiftAlbum
//
//  Created by RossSong on 2017. 5. 16..
//  Copyright © 2017년 RossSong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PhotoViewController: UIViewController, XMLParserDelegate, UITextFieldDelegate{
    let bottomMargin:CGFloat = 60

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelLoading: UILabel!
    @IBOutlet weak var textFieldInterval: UITextField!
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        let photoViewModel = PhotoViewModel(feedsService: FlickrFeedsAPIService.sharedInstance,
                                            networkManager: NetworkManagerService.sharedInstance)
        addBindsToViewModel(photoViewModel)
        photoViewModel.startDownloadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    fileprivate func addBindsToViewModel(_ viewModel: PhotoViewModel) {
        //textField interval 은 1 에서 10 까지만 입력가능 하고, 입력된 값에 따라 타이머가 조정되어야 하므로 양방향으로 연결.
        textFieldInterval.rx.text.orEmpty.bindTo(viewModel.interval).addDisposableTo(disposeBag)
        viewModel.interval.asObservable().bindTo(self.textFieldInterval.rx.text).addDisposableTo(disposeBag)
        
        //Flickr Feeds를 수신 완료하면 "Loading" 레이블이 사라지도록 연결
        viewModel.isLabelLoadingHidden.asObservable().bindTo(self.labelLoading.rx.isHidden).addDisposableTo(disposeBag)
        
        //Fade In/Fade Out 효과를 주기 위해서 데이터가 바뀌면 이벤트를 받아서 View에서 애니메이션과 함께 변경하도록 연결
        viewModel.currentImage.asObservable().subscribe(onNext: { [unowned self] image in
            self.updateImage(image);
        }).addDisposableTo(disposeBag)
        
        //textField 이벤트들에 대한 처리 연결
        textFieldInterval.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.addDoneButtonOnKeyboard()
            })
            .addDisposableTo(disposeBag)
        
        textFieldInterval.rx.controlEvent([.editingChanged])
            .asObservable()
            .subscribe(onNext: { _ in
                viewModel.fieldIntervalChanged()
            })
            .addDisposableTo(disposeBag)
        
        textFieldInterval.rx.controlEvent([.editingDidEndOnExit])
            .asObservable()
            .subscribe(onNext: { _ in
                self.doneButtonAction()
            })
            .addDisposableTo(disposeBag)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        //숫자 패드가 올라올 때 interval 입력 textField가 가리지 않도록 처리
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.constraintBottom.constant = keyboardHeight + bottomMargin
    }
    
    func addDoneButtonOnKeyboard() {
        //숫자 패드에는 Done이 없으므로 AccesssoryView로 추가함.
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(PhotoViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.textFieldInterval.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.view.endEditing(true)
        self.constraintBottom.constant = bottomMargin
    }
    
    func updateImage(_ image:UIImage) {
        //Fade out/Fade In 하면서 이미지를 교체
        UIView.transition(with: self.imageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.imageView.alpha = 0;
        },
                          completion:{ (finished: Bool) -> () in
                            self.imageView.image = image;
                            UIView.transition(with: self.imageView,
                                              duration: 0.3,
                                              options: .transitionCrossDissolve,
                                              animations: {
                                                self.imageView.alpha = 1;
                            },
                                              completion:nil)
        })
    }
}
