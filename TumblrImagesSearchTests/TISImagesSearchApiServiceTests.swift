//
//  TISImagesSearchApiServiceTests.swift
//  TumblrImagesSearchTests
//
//  Created by Mihail COSTRACI on 07.02.2022.
//

import XCTest
import Combine
@testable import TumblrImagesSearch

class TISImagesSearchApiServiceTests: XCTestCase {

    var cancelBag = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        cancelBag = Set<AnyCancellable>()
    }

    func test_should_return_search_results() throws {

        let searchTag = "cars"

        let urlSessioMock = TSIURLSessionMock()
        let mockClient = TSIAPIClientMock(urlSesssion: urlSessioMock)
        let service = TSITumblrAPIService(client: mockClient)
        let reponseMock = HTTPURLResponseMock(url: TSIContentActionsEndpoint.searchImages(tag: searchTag).fullURL,
                                              statusCode: 200,
                                              bodyData: loadJSONData(name: "Cars-Images"))!

        urlSessioMock.add(response: reponseMock)

        service
            .searchImages(withTag: searchTag)
            .sink { completion in

                if case .failure(let error) = completion {
                    print("Failure with error: \(error)")
                    XCTFail(error.localizedDescription)
                }

            } receiveValue: { results in

                XCTAssertEqual(results.response.count, 20)

                var foundedImages = [TSIPhotoModel]()
                results.response.forEach { model  in
                    guard let photos = model.photos, !photos.isEmpty else { return }

                    photos.forEach { photoModel in
                        if !photoModel.originalSize.url.isEmpty {
                            foundedImages.append(photoModel)
                        }
                    }
                }

                XCTAssertEqual(foundedImages.count, 25)
            }.store(in: &cancelBag)

    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
