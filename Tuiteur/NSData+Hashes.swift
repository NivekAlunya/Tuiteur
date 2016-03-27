//
//  NSData+Hashes.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/27/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

extension NSData {
    func md5() -> String {
        if let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH)) {
            let resultBytes = UnsafeMutablePointer<CUnsignedChar>(result.mutableBytes)
            CC_MD5(self.bytes, CC_LONG(self.length), resultBytes)
            let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result.length)
            
            let MD5 = NSMutableString()
            
            for c in resultEnumerator {
                MD5.appendFormat("%02x", c)
            }
            
            return MD5 as String
        }
        return ""
    }
}