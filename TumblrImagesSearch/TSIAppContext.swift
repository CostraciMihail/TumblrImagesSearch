//
//  TSIAppContext.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//  Copyright © 2022 iOS Developer. All rights reserved.
//

import Foundation

final class TSIAppContext {
    // MARK: - Properties
    //
    static var bundleID: String {
        return Bundle.main.bundleIdentifier ?? ""
    }

    static let apiKey = "CcEqqSrYdQ5qTHFWssSMof4tPZ89sfx6AXYNQ4eoXHMgPJE03U"
}
