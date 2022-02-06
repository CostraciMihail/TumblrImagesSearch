//
//  TISImageDetailsViewController.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import UIKit
import Combine

class TISImageDetailsViewController: UIViewController {

    private let imageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        return $0
    }(UIImageView())

    let tumblrService = TSITumblrAPIService()
    private var cancelBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchImages(withTag: "cats")
    }

    func setupUI() {

        // View
        title = "Image Name"

        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        ])

    }

    func loadImage() {
        // Create URL
          let url = URL(string: "https://cdn.cocoacasts.com/cc00ceb0c6bff0d536f25454d50223875d5c79f1/above-the-clouds.jpg")!

          // Create Data Task
          let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
              if let data = data {
                  DispatchQueue.main.async { [weak self] in
                      guard let self = self else { return }
                      // Create Image and Update Image View
                      self.imageView.image = UIImage(data: data)
                  }
              }
          }

          // Start Data Task
          dataTask.resume()
    }

    func searchImages(withTag tag: String, limit: Int? = 10) {

        tumblrService.searchImages(withTag: tag)
            .sink { completion in
                if case .failure(let error) = completion {
                    debugPrint("Error: \(error)")
                }
            } receiveValue: { results in

                let arrWithImages = results.response.compactMap { element -> TSISearchResultModel? in

                    guard let photos = element.photos,
                          photos.contains(where: { $0.originalSize.url != "" }) else {
                        return nil
                    }

                    return element
                }

                print("!!! ArrayWithImages: \(arrWithImages.count)")

            }.store(in: &cancelBag)
    }
}
