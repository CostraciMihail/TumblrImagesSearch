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
    func downloaImage(from url: String) -> AnyPublisher<UIImage, TSIError>
}

class TSITumblrAPIService: TSITumblrAPIServiceInterface {

    var client: TSIAPIClientInterface

    init(client: TSIAPIClientInterface = TSIAPIClient()) {
      self.client = client
    }

    func searchImages(withTag tag: String) -> AnyPublisher<TSISearchResultsResponse, TSIError> {
        let router = TSIContentActionsEndpoint.searchImages(tag: tag)
        let request = URLRequest(service: router)
        return client.run(request, JSONDecoder())
            .map(\.value)
            .eraseToAnyPublisher()
    }

    func downloaImage(from url: String) -> AnyPublisher<UIImage, TSIError> {
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
