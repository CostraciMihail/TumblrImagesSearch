//
//  TISImagesSearchViewModel.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation
import Combine

enum ImageSection: Int, Hashable {
    case main
}

struct ImageItem: Hashable {
    let title: String
    let url: String
}

protocol TISImagesSearchViewModelInterface: AnyObject {
    var service: TSITumblrAPIServiceInterface { get set }
    var foundImages: [TSISearchResultModel] { get set }

    func searchImages(withTag tag: String)
}

class TISImagesSearchViewModel {
    
    @Published var foundImages = [TSISearchResultModel]()
    var service: TSITumblrAPIServiceInterface
    private var cancelBag = Set<AnyCancellable>()

    init(service: TSITumblrAPIServiceInterface) {
        self.service = service
    }

    var items: [ImageItem] {
        var imageItems = [ImageItem]()
        foundImages.forEach({ item in
            guard let photos = item.photos, !photos.isEmpty else { return }
            photos.forEach { photoModel in
                if !photoModel.originalSize.url.isEmpty {
                    let title = item.tags?.first ?? "Image"
                    imageItems.append(ImageItem(title: title, url: photoModel.originalSize.url))
                }
            }
        })

        return imageItems
    }

    func searchImages(withTag tag: String) {
        service.searchImages(withTag: tag)
            .sink { completion in
                if case .failure(let error) = completion {
                    debugPrint("Error: \(error)")
                }
            } receiveValue: { [weak self] results in

                guard let self = self else { return }
                let images = results.response.compactMap { item -> TSISearchResultModel? in
                    guard let photos = item.photos, !photos.isEmpty,
                          photos.contains(where: { $0.originalSize.url != "" }) else {
                              return nil
                          }
                    return item
                }
                self.foundImages = images

            }.store(in: &cancelBag)
    }

    func removeFoundedImages() {
        foundImages.removeAll()
    }
}
