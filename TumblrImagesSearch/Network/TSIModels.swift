//
//  TSIModels.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 09.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation

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
