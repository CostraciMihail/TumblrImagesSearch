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

    func test_should_return_search_results() throws {
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

                let containsSearchedTag = results.response.contains { [weak self] model in
                    guard let self = self,
                    let contains = model.tags?.contains(self.searchTag) else {
                        return false
                    }
                    return contains
                }

                XCTAssertTrue(containsSearchedTag)

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
