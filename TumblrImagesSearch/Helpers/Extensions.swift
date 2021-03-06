//
//  Extensions.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 08.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizeImage(to targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

extension UITableViewCell {
    public static var identifier: String {
        NSStringFromClass(self)
    }
}
