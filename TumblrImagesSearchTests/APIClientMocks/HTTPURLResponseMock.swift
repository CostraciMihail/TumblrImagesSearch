//
//  HTTPURLResponseMock.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 09.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation

class HTTPURLResponseMock: HTTPURLResponse {
    
    var bodyData: Data
    
    init?(url: URL,
          statusCode: Int,
          httpVersion HTTPVersion: String? = nil,
          headerFields: [String : String]? = nil,
          bodyData: Data = Data()) {
        
        self.bodyData = bodyData
        
        super.init(url: url,
                   statusCode: statusCode,
                   httpVersion: HTTPVersion,
                   headerFields: headerFields)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
