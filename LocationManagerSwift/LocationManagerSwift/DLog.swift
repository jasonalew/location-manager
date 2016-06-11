//
//  DLog.swift
//  LocationManagerSwift
//
//  Created by Jason Lew on 6/11/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation

class DLog {
    class func print(items: Any, filePath: String = #file, function: String = #function) {
        var className = ""
        if let rangeOfSlash = filePath.rangeOfString("/", options: .BackwardsSearch, range: nil, locale: nil) {
            className = String(filePath.characters.suffixFrom(rangeOfSlash.endIndex))
        }
        #if DEBUG
            Swift.print("\(className) - \(function) - \(items)\n")
        #endif
    }
}
