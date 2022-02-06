//
//  TSIHelpers.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation

func localize(_ string: String, tableName: String? = nil, value: String = "", comment: String = "") -> String {

    return NSLocalizedString(string, tableName: tableName, bundle: Bundle.main, value: value, comment: comment)
}
