//
//  DLog.swift
//  LocationManagerSwift
//
//  Created by Jason Lew on 6/11/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation

class DLog {
    class func print(items: Any) {
        #if DEBUG
            print("\(items) \(#function)\n")
        #endif
    }
}
