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
    var item: ImageItem { get set }

    func loadImage() -> AnyPublisher<UIImage, TSIError>
}

/// TISImageDetailsViewModel
class TISImageDetailsViewModel: TISImageDetailsViewModelInterface {

    var item: ImageItem
    var service: TSITumblrAPIServiceInterface
    private var cancelBag = Set<AnyCancellable>()

    init(service: TSITumblrAPIServiceInterface = TSITumblrAPIService(), item: ImageItem) {
        self.service = service
        self.item = item
    }

    func loadImage() -> AnyPublisher<UIImage, TSIError> {
        return service.downloaImage(from: item.url)
    }
}
