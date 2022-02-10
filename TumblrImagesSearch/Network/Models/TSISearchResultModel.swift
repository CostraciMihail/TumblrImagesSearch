//
//  TSISearchResultModel.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 10.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation

struct TSISearchResultModel: Codable {
    let tags: [String]?
    let blogName: String?
    let blog: TSIBlogModel?
    let photos: [TSIPhotoModel]?
}

extension Array where Element == TSISearchResultModel {

    var allImageItems: [ImageItem] {
        var array = [ImageItem]()
        self.forEach({ item in
            guard let photos = item.photos, !photos.isEmpty else { return }
            photos.forEach { photoModel in
                if !photoModel.originalSize.url.isEmpty {
                    let title = item.tags?.first ?? "Image"
                    array.append(ImageItem(title: title, url: photoModel.originalSize.url))
                }
            }
        })
        return array
    }

    var modelsWithPhotos: [TSISearchResultModel] {
        return self.compactMap { item -> TSISearchResultModel? in
            guard let photos = item.photos, !photos.isEmpty,
                  photos.contains(where: { !$0.originalSize.url.isEmpty }) else {
                      return nil
                  }
            return item
        }
    }
}
