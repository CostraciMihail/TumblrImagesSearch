//
//  TISImageCell.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 08.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation
import UIKit

class TISImageCell: UITableViewCell {

    enum LayoutConstant {
        static let imageHeight: CGFloat = 300
        static let imageSize = CGSize(width: 300, height: 300)
    }

    var image = UIImageView(frame: .zero)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        selectionStyle = .none
        setupImageView()
    }

    func setupImageView() {
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        contentView.addSubview(image)

        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: LayoutConstant.imageHeight),
            image.heightAnchor.constraint(equalToConstant: LayoutConstant.imageHeight),

            image.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            image.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -10),

            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0)
        ])
    }

    func configure(with image: UIImage?) {
        guard let image = image else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.image.image = nil
            }
            return
        }

        DispatchQueue.global(qos: .userInteractive).async {
            let imageSize = CGSize(width: LayoutConstant.imageHeight,
                                   height: LayoutConstant.imageHeight)

            let resizedImage = image.resizeImage(to: imageSize)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.image.image = resizedImage
            }
        }
    }
}
