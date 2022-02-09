//
//  TSIURLSessionMock.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 09.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation
import Combine

class TSIURLSessionMock: URLSession {
    
    private var response: HTTPURLResponseMock?
    
    func add(response: HTTPURLResponseMock) {
        self.response = response
    }
    
    public func tsi_dataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: HTTPURLResponse), TSIError> {
        
        return Future<(data: Data, response: HTTPURLResponse), TSIError> { promise in
            
            if let response = self.response {
                promise(.success((data: response.bodyData, response: response)))
                
            } else {
                promise(.failure(TSIError(code: TSIErrorKeys.MOCK_RESPONSE_IS_NOT_SETTED.rawValue)))
            }
            
        }.eraseToAnyPublisher()
    }
}
