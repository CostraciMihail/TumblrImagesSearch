//
//  TISImageDetailsViewModel.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 09.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation
import UIKit
import Combine

/// TISImageDetailsViewModelInterface
protocol TISImageDetailsViewModelInterface: AnyObject {
    var service: TSITumblrAPIServiceInterface { get set }
    var item: TSISearchResultModel { get set }

    func loadImage() -> AnyPublisher<UIImage, TSIError>
}

/// TISImageDetailsViewModel
class TISImageDetailsViewModel: TISImageDetailsViewModelInterface {

    var item: TSISearchResultModel
    var service: TSITumblrAPIServiceInterface
    private var cancelBag = Set<AnyCancellable>()

    init(service: TSITumblrAPIServiceInterface, item: TSISearchResultModel) {
        self.service = service
        self.item = item
    }

    func loadImage() -> AnyPublisher<UIImage, TSIError> {
        guard let url = item.photos?.first?.originalSize.url else {
            return Future { promise in
                promise(.failure(TSIError(code: TSIErrorKeys.UNKNOWN_ERROR.rawValue)))
            }.eraseToAnyPublisher()
        }
        return service.downloaImageTemp(from: url)
    }

}
