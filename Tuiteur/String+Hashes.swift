//
//  String+Hashes.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/26/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

extension String {
    func md5() -> String {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        {
            if let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH)) {
                let resultBytes = UnsafeMutablePointer<CUnsignedChar>(result.mutableBytes)
                CC_MD5(data.bytes, CC_LONG(data.length), resultBytes)
                let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result.length)
                
                let MD5 = NSMutableString()
                
                for c in resultEnumerator {
                    MD5.appendFormat("%02x", c)
                }
                
                return MD5 as String
            }
        }
        return ""
    }
}