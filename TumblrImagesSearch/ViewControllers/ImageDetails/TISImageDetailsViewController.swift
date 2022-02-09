//
//  TISImageDetailsViewController.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import UIKit
import Combine

/// TISImageDetailsViewController
class TISImageDetailsViewController: UIViewController {
    // MARK: - Properties

    private let imageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        return $0
    }(UIImageView())

    private let viewModel: TISImageDetailsViewModelInterface
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModle: TISImageDetailsViewModelInterface) {
        self.viewModel = viewModle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    // MARK: - UI Setup

    func setupUI() {
        title = viewModel.item.tags?.first ?? "Image Tag"
        view.backgroundColor = .white
        setupNavigationBar()
        setupImageView()
    }

    func setupNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = true
    }

    func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        ])
    }

    // MARK: - Binding

    func bind() {
        viewModel
            .loadImage()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {_ in}) { [weak self] image in
                self?.imageView.image = image
            }.store(in: &cancelBag)
    }

    // MARK: - Deinitialization

    deinit {
        cancelBag.removeAll()
    }
}
