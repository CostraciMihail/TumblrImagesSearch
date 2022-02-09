//
//  TISImagesSearchApiService.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation
import Combine
import UIKit

protocol TSITumblrAPIServiceInterface {
    func searchImages(withTag tag: String) -> AnyPublisher<TSISearchResultsResponse, TSIError>
    func downloadImage(fromUrl url: String) -> AnyPublisher<UIImage, TSIError>
    func downloaImageTemp(from url: String) -> AnyPublisher<UIImage, TSIError>
}

class TSITumblrAPIService: TSITumblrAPIServiceInterface {

    private let client = TSIAPIClient()

    func searchImages(withTag tag: String) -> AnyPublisher<TSISearchResultsResponse, TSIError> {
        let router = ExpContentActionsEndpoint.searchImages(tag: tag)
        let request = URLRequest(service: router)
        return client.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    func downloadImage(fromUrl url: String) -> AnyPublisher<UIImage, TSIError> {
        let router = ExpContentActionsEndpoint.downloadImage(fromUrl: url)
        let request = URLRequest(service: router)
        return client.downloadImage(request)
            .map({ image in
                image
            })
            .eraseToAnyPublisher()
    }

    func downloaImageTemp(from url: String) -> AnyPublisher<UIImage, TSIError> {
        let url = URL(string: url)!
        let reqeust = URLRequest(url: url)
        
        return URLSession.shared
            .dataTaskPublisher(for: reqeust)
            .tryMap { data, response in
                UIImage(data: data)!
            }
            .mapError({ error -> TSIError in
                return TSIError.toError(error: error)
            })
            .eraseToAnyPublisher()
    }
}

struct TSISearchResultsResponse: Codable {
    var response: [TSISearchResultModel]
    var meta: TSIMetaDTO
}

struct TSIMetaDTO: Codable {
    let status: Int
    let msg: String
}

struct TSISearchResultModel: Codable {
    let tags: [String]?
    let blogName: String?
    let blog: TSIBlogModel?
    let photos: [TSIPhotoModel]?
}

struct TSIBlogModel: Codable {
    let name: String?
    let title: String?
    let description: String?
}

struct TSIPhotoModel: Codable {
    let originalSize: TSIPhotoSizeModel
}

struct TSIPhotoSizeModel: Codable {
    let url: String
}
