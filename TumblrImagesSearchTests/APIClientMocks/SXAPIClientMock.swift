//
//  TSIAPIClientMock.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 09.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation
import Combine

class TSIAPIClientMock: TSIErrorReponse, TSIAPIClientInterface {
    
    private var urlSesssion: TSIURLSessionMock
    
    init(urlSesssion: TSIURLSessionMock) {
        self.urlSesssion = urlSesssion
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<APIClientResponse<T>, TSIError> {
        
        debugRequest(request)
        
        return urlSesssion
            .tsi_dataTaskPublisher(for: request)
            .tryMap { result -> APIClientResponse<T> in
                
                return try self.processResponse(result, decoder: decoder)
            }.mapError({ error -> TSIError in
                
                return TSIError.toError(error: error)
            })
            .eraseToAnyPublisher()
    }
    
}
