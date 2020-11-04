//
//  WebiiAuthSignatureUtil.swift
//  Zond
//
//  Created by yu xiaohe on 2020/10/30.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import Foundation

extension String {
    func hmac(by algorithm: Algorithm, key: [UInt8]) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: algorithm.digestLength())
        CCHmac(algorithm.algorithm(), key, key.count, self.bytes, self.bytes.count, &result)
        return result
    }
    
    func hashHex(by algorithm: Algorithm) -> String {
        return algorithm.hash(string: self).hexString
    }
    
     func hash(by algorithm: Algorithm) -> [UInt8] {
        return algorithm.hash(string: self)
     }
}


enum Algorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func algorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:    result = kCCHmacAlgMD5
        case .SHA1:   result = kCCHmacAlgSHA1
        case .SHA224: result = kCCHmacAlgSHA224
        case .SHA256: result = kCCHmacAlgSHA256
        case .SHA384: result = kCCHmacAlgSHA384
        case .SHA512: result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:    result = CC_MD5_DIGEST_LENGTH
        case .SHA1:   result = CC_SHA1_DIGEST_LENGTH
        case .SHA224: result = CC_SHA224_DIGEST_LENGTH
        case .SHA256: result = CC_SHA256_DIGEST_LENGTH
        case .SHA384: result = CC_SHA384_DIGEST_LENGTH
        case .SHA512: result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
    
    func hash(string: String) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: self.digestLength())
        switch self {
        case .MD5:    CC_MD5(   string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA1:   CC_SHA1(  string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA224: CC_SHA224(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA256: CC_SHA256(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA384: CC_SHA384(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA512: CC_SHA512(string.bytes, CC_LONG(string.bytes.count), &hash)
        }
        return hash
    }
}

extension Array where Element == UInt8 {
    var hexString: String {
        return self.reduce(""){$0 + String(format: "%02x", $1)}
    }
    
    var base64String: String {
        return self.data.base64EncodedString(options: Data.Base64EncodingOptions.lineLength76Characters)
    }
    
    var data: Data {
        return Data(self)
    }
}

extension String {
    var bytes: [UInt8] {
        return [UInt8](self.utf8)
    }
}

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

class WebiiAuthSignatureUtil: NSObject {

    func genUrlAuth(url:String)->String{
        let sp:UserDefaults = UserDefaults.standard
        let systemId:String? = sp.object(forKey: "agri_mcfly_client_id") as! String?
        let randomNumber:String = randomString(16)
        let unixTimeStamp:String = curTimestamp()
        let strKey:String? = sp.object(forKey: "agri_mcfly_key") as! String?
        let signature:String = genCurSignature(clientId:systemId ?? "", unixTimeStamp:unixTimeStamp, randomNumber:randomNumber, key:strKey ?? "")

        let strURL_PREFIX:String? = sp.object(forKey:"agri_mcfly_url_prefix") as! String?
        let strURL:String = "\(strURL_PREFIX ?? "")\(url)&systemId=\(systemId ?? "")&randomNumber=\(randomNumber)&unixTimeStamp=\(unixTimeStamp)&signature=\(signature)"
                //Globle.cookie
        print("genUrlAuth \(strURL)")
        return strURL
    }
     
    func genCurSignature(clientId:String, unixTimeStamp:String,
                         randomNumber:String, key:String)->String{
        let strToSign:String = clientId+randomNumber+unixTimeStamp+key
        print("strToSign:\(strToSign)")
        let signature:String = generateSignature(data:strToSign, key:key);
        return signature;
    }
     
    func randomString(_ length:Int)->String{
        let str:String="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var sb:String = ""
        for _ in 0..<length{
            let number:Int = Int(arc4random_uniform(62))
            let index = str.index(str.startIndex, offsetBy: number)
            sb.append(str[index]);
        }
        return sb;
    }
     
    func curTimestamp() -> String{
        //获取当前时间
        let  now =  NSDate ()
         
        // 创建一个日期格式器
        //let  dformatter =  NSDateFormatter ()
        //dformatter.dateFormat =  "yyyy年MM月dd日 HH:mm:ss"
        //print ( "当前日期时间：\(dformatter.stringFromDate(now))" )
         
        //当前时间的时间戳
        let  timeInterval: TimeInterval  = now.timeIntervalSince1970
        let  timeStamp =  Int (timeInterval)
        return timeStamp.description
    }
     
    func generateSignature(data:String, key:String) -> String{
        let tData = data.hmac(by: .SHA256, key: key.bytes)
        let signature = tData.hexString.lowercased()
        return signature
    }
}
