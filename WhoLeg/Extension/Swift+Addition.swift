//
//  Swift+Addition.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/22.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Foundation

extension Array {
    mutating func shuffle() {
        let n = count
        for i in 0 ..< n {
            let r = Int(arc4random_uniform(UInt32(n - i))) + i
            swapAt(i, r)
        }
    }
}
