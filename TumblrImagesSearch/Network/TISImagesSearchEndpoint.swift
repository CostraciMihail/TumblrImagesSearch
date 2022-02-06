//
//  TISImagesSearchEndpoint.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation

enum ExpContentActions {
    case searchImages(tag: String)
}

enum ExpContentActionsEndpoint: EndpointProtocol {

    case searchImages(tag: String)
    case downloadImage(fromUrl: String)

    var path: String {
        switch self {
        case .searchImages(_): return "/v2/tagged"
        case.downloadImage(_): return ""
        }
    }

    var task: HTTPTask {
        let parameters: Parameters? = nil
        var urlParameters: [String: Any]? = nil

        switch self {
        case .searchImages(let tag):
            urlParameters = [:]
            urlParameters?["tag"] = tag
            urlParameters?["api_key"] = TSIAppContext.apiKey
        default: break
        }

        return .requestParameters(bodyParameters: parameters, urlParameters: urlParameters)
    }

    var parameterEncoding: ParameterEncoding {
        switch self {
        case .searchImages(_): return .url
        case .downloadImage(_): return .date
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .searchImages(_): return .get
        case .downloadImage(_): return .get
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .searchImages(_): return nil
        case .downloadImage(_):
            return ["Content-Type": "image/jpeg"]
        }
    }

    var baseURL: URL {
        switch self {
        case .downloadImage(let imageUrl): return URL(string: imageUrl)!
        default:
            guard let url = URL(string: Config.baseURL) else {
                fatalError("\(String(describing: self)): Wrong baseURL \(Config.baseURL)")
            }
            return url
        }
    }
}
