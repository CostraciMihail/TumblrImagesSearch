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
        foundImages.allImageItems
    }

    func searchImages(withTag tag: String) {
        service.searchImages(withTag: tag)
            .sink { completion in
                if case .failure(let error) = completion {
                    debugPrint("Error: \(error)")
                }
            } receiveValue: { [weak self] results in
                guard let self = self else { return }
                self.foundImages = results.response.modelsWithPhotos // images
            }.store(in: &cancelBag)
    }

    func removeFoundedImages() {
        foundImages.removeAll()
    }
}
