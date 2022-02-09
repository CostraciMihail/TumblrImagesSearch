//
//  APIClient.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//

import Foundation
import Combine
import UIKit

struct APIClientResponse<T> {
    let value: T
    let response: URLResponse
}

struct TSIAPIClient: TSIErrorReponse {
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<APIClientResponse<T>, TSIError> {
        
        debugRequest(request)
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> APIClientResponse<T> in
            
                return try self.processResponse(result, decoder: decoder)
        }.mapError({ error -> TSIError in
            
            return TSIError.toError(error: error)
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func downloadImage(_ request: URLRequest) -> AnyPublisher<UIImage, TSIError> {

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let image = UIImage(data: data) else {
                    throw TSIError(code: TSIErrorKeys.UNKNOWN_ERROR.rawValue)
                }
                return image
            }
            .mapError({ error -> TSIError in
                return TSIError.toError(error: error)
            })
            .eraseToAnyPublisher()
    }


}
