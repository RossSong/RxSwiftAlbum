//
//  testPhotoViewModel.swift
//  
//
//  Created by RossSong on 2017. 5. 17..
//
//

import XCTest
@testable import RxSwiftAlbum

class MockNetworkManager : NetworkManager {
    func getFeeds(_ url:String, handler:@escaping (_ xml:String) -> ()) {
        handler("<xml></xml>")
    }
    
    func downloadImage (_ stringThumbnailURL:String, result:@escaping (_ image:UIImage) -> ()) {
        result(UIImage())
    }
}

class MockFeedsService : FeedsAPIService {
    var count:Int = 1
    var imageURL:String? = "https://farm5.staticflickr.com/4165/34674530146_23b5e5b919_b.jpg";
    
    func getFeeds() {
        //do nothing
    }
    
    func countOfFeeds() -> Int {
        return count
    }
    
    func getImageURL(_ index:Int) -> String? {
        if 999 == index {
            return nil
        }
        
        return imageURL
    }
}

class testPhotoViewModel: XCTestCase {
    var viewModel : PhotoViewModel!
    var feedsService : MockFeedsService!
    var networkManager : MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        feedsService = MockFeedsService()
        networkManager = MockNetworkManager()
        viewModel = PhotoViewModel(feedsService: feedsService, networkManager: networkManager)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        viewModel = nil
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testInit() {
        XCTAssert(1 == viewModel.feedsService.countOfFeeds())
        XCTAssert("https://farm5.staticflickr.com/4165/34674530146_23b5e5b919_b.jpg" == viewModel.feedsService.getImageURL(0))
        XCTAssert("3" == viewModel.interval.value)
        XCTAssert(false == viewModel.isLabelLoadingHidden.value)
    }
    
    func doUpdateImageViewAndGetMore(_ count:Int, imageIndex:Int, isHidden:Bool){
        let image = UIImage()
        self.feedsService.count = count
        
        let expt = expectation(description: "Waiting...")
        self.viewModel.updateImageViewAndGetMore(image) {
            XCTAssert(imageIndex == self.self.viewModel.imageIndex)
            XCTAssert(isHidden == self.viewModel.isLabelLoadingHidden.value)
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testUpdateImageViewAndGetMore1() {
        doUpdateImageViewAndGetMore(0, imageIndex:0, isHidden:false)
    }
    
    func testUpdateImageViewAndGetMore2() {
        doUpdateImageViewAndGetMore(5, imageIndex:1, isHidden:true)
    }
    
    func testUpdateImageViewAndGetMore3() {
        doUpdateImageViewAndGetMore(1, imageIndex:0, isHidden:true)
    }
    
    func testDownloadImage() {
        viewModel.downloadImage("https://farm5.staticflickr.com/4165/34674530146_23b5e5b919_b.jpg") { image in
            XCTAssert(nil != image)
        }
    }
    
    func testUpdateCurrentImage1() {
        viewModel.imageIndex = 2
        viewModel.updateCurrentImage() { string in
            XCTAssert(nil == string)
        }
    }
    
    func testUpdateCurrentImage2() {
        viewModel.imageIndex = 999
        feedsService.count = 1000
        viewModel.updateCurrentImage() { string in
            XCTAssert(nil == string)
        }
    }
    
    func testUpdateCurrentImage3() {
        viewModel.imageIndex = 0
        viewModel.updateCurrentImage() { string in
            XCTAssert("https://farm5.staticflickr.com/4165/34674530146_23b5e5b919_b.jpg" == string)
        }
    }
    
    func testStartDownloadImage1() {
        viewModel.interval.value = "1"
        let expt = expectation(description: "Waiting...")
        viewModel.startDownloadImage() { ret in
            self.viewModel.disposeBag = nil
            XCTAssert(nil != ret)
            XCTAssert("completed" == ret)
            expt.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testStartDownloadImage2() {
        viewModel.interval.value = "1"
        feedsService.imageURL = nil
        let expt = expectation(description: "Waiting...")
        viewModel.startDownloadImage() { ret in
            self.viewModel.disposeBag = nil
            XCTAssert(nil != ret)
            XCTAssert("no imageURL" == ret)
            expt.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func doTestCheckFieldInterval(_ interval:String, expected:String) {
        viewModel.interval.value = interval
        viewModel.fieldIntervalChanged()
        XCTAssert(expected == viewModel.interval.value)
    }
    
    func testCheckFieldInterval() {
        doTestCheckFieldInterval("-100", expected: "1")
        doTestCheckFieldInterval("-2", expected: "1")
        doTestCheckFieldInterval("-1", expected: "1")
        doTestCheckFieldInterval("1", expected: "1")
        doTestCheckFieldInterval("2", expected: "2")
        doTestCheckFieldInterval("3", expected: "3")
        doTestCheckFieldInterval("4", expected: "4")
        doTestCheckFieldInterval("5", expected: "5")
        doTestCheckFieldInterval("6", expected: "6")
        doTestCheckFieldInterval("7", expected: "7")
        doTestCheckFieldInterval("8", expected: "8")
        doTestCheckFieldInterval("9", expected: "9")
        doTestCheckFieldInterval("10", expected: "10")
        doTestCheckFieldInterval("11", expected: "10")
        doTestCheckFieldInterval("100", expected: "10")
    }
}
