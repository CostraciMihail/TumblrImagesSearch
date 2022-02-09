//
//  TISEndpointProtocol.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {

    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String: Any]

public enum HTTPTask {

    case request
    case requestParameters(bodyParameters: Parameters?,
        urlParameters: Parameters?)
}

enum ParameterEncoding {
    
    case url
    case json
    case date
}

protocol EndpointProtocol {

    var baseURL: URL { get }
    var path: String { get }
    var parameterEncoding: ParameterEncoding { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}

extension EndpointProtocol {

    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("\(String(describing: self)): Wrong baseURL \(Config.baseURL)")
        }
        return url
    }

    var headers: HTTPHeaders? {
        let dict = ["Content-Type" : "application/json"]
        return dict
    }
}


extension URLComponents {

    init(service: EndpointProtocol) {

        let url = service.baseURL.appendingPathComponent(service.path)
        self.init(url: url, resolvingAgainstBaseURL: false)!

        guard case .requestParameters(_, let urlParams) = service.task else { return }

        let newParams = urlParams?.filter({ (dictionary) -> Bool in
            return !(dictionary.value is [Int])
        })

        queryItems = newParams?.map { URLQueryItem(name: $0, value: String(describing: $1))}

        if let arrayParams = urlParams?.filter({ ($0.value is [Int]) }) as? [String: [Int]] {
            arrayParams.forEach { (key, values) in
                queryItems?.append(contentsOf: values.map({ URLQueryItem(name: key, value: "\($0)") }))
            }
        }
    }
}

extension URLRequest {

    init(service: EndpointProtocol) {

        let component = URLComponents(service: service)
        self.init(url: component.url!)

        service.headers?.forEach({ addValue($1, forHTTPHeaderField: $0 )})
        self.httpMethod = service.httpMethod.rawValue


        guard case .requestParameters(let bodyParams, _) = service.task, let parameters = bodyParams else { return }

        httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    }

}
