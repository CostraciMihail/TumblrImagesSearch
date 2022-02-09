//
//  TISImagesSearchViewModelTest.swift
//  TumblrImagesSearchTests
//
//  Created by Mihail COSTRACI on 09.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import XCTest
import Combine

class TISImagesSearchViewModelTest: XCTestCase {

    let searchTag = "cars"
    var service: TSITumblrAPIServiceInterface!
    var urlSessioMock: TSIURLSessionMock!
    var cancelBag = Set<AnyCancellable>()

    override func setUp() {
        urlSessioMock = TSIURLSessionMock()
        let mockClient = TSIAPIClientMock(urlSesssion: urlSessioMock)
        service = TSITumblrAPIService(client: mockClient)
        let reponseMock = HTTPURLResponseMock(url: TSIContentActionsEndpoint.searchImages(tag: searchTag).fullURL,
                                              statusCode: 200,
                                              bodyData: loadJSONData(name: "Cars-Images"))!

        urlSessioMock.add(response: reponseMock)
    }

    override func tearDownWithError() throws {
        cancelBag = Set<AnyCancellable>()
    }

    func test_search_view_model_should_return_searched_images() throws {
        let expectations = expectation(description: "Expectation")
        let viewModel = TISImagesSearchViewModel(service: service)
        viewModel.searchImages(withTag: searchTag)

        viewModel.$foundImages.sink {_ in} receiveValue: { models in
            expectations.fulfill()
        }.store(in: &cancelBag)

        wait(for: [expectations], timeout: 1)
        XCTAssertEqual(viewModel.foundImages.count, 20)
        XCTAssertEqual(viewModel.items.count, 25)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
