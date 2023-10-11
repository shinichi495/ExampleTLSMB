//
//  Example.swift
//  Test
//
//  Created by Nam Pham on 10/11/23.
//

import Foundation

class PKCS12 {
    var label:String?
    var keyID:Data?
    var trust:SecTrust?
    var certChain:[SecTrust]?
    var identity:SecIdentity?
    
    var securityError:OSStatus
    
    init(data:Data, password:String) {
        var items:CFArray?
        let certOptions:NSDictionary = [kSecImportExportPassphrase as NSString:password as NSString]
       
        // import certificate to read its entries
        self.securityError =  SecPKCS12Import(data as NSData, certOptions, &items)
        
        if self.securityError == errSecSuccess {
            let certItems:Array = (items! as Array)
            let dict:Dictionary<String, AnyObject> = certItems.first! as! Dictionary<String, AnyObject>;
            
            self.label = dict[kSecImportItemLabel as String] as? String
            self.keyID = dict[kSecImportItemKeyID as String] as? Data
            self.trust = dict[kSecImportItemTrust as String] as! SecTrust?
            self.certChain = dict[kSecImportItemCertChain as String] as? Array<SecTrust>
            self.identity = dict[kSecImportItemIdentity as String] as! SecIdentity?
        }
        
        print(self.securityError)
    }
    
    convenience init(mainBundleResource: String, resourceType:String, password:String) {
        var sdkPKCS12Bundle: Bundle {
            let bundle = Bundle(url: Bundle.main.bundleURL.appendingPathComponent("Frameworks").appendingPathComponent("sdkEbanking.framework"))
            return bundle ?? Bundle.init(identifier: SSDKBUNDLE_STRING) ?? Bundle.main
        }
        let dataPKCS12 = NSData(contentsOfFile: sdkPKCS12Bundle.path(forResource: mainBundleResource, ofType:resourceType)!)! as Data
        self.init(data: dataPKCS12, password: password)
    }
    
    func urlCredential()  -> URLCredential  {
        return URLCredential(
            identity: self.identity!,
            certificates: self.certChain!,
            persistence: URLCredential.Persistence.forSession);
        
    }
}
