//
//  TSIHelpers.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation
import UIKit

func localize(_ string: String, tableName: String? = nil, value: String = "", comment: String = "") -> String {

    return NSLocalizedString(string, tableName: tableName, bundle: Bundle.main, value: value, comment: comment)
}

func showMessage(_ title: String? = nil,
                 message: String,
                 from: UIViewController,
                 handler: ((UIAlertAction) -> Void)? = nil) {

    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)

    let dismissAction = UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: handler)

    alertController.addAction(dismissAction)

    DispatchQueue.main.async {
        from.present(alertController, animated: true, completion: nil)
    }
}
