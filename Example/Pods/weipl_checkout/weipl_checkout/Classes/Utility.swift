// Utility.swift
// weipl_checkout
// Created by Wordline ePayments India on 05/10/2022
// Copyright © 2022 Wordline ePayments India. All rights reserved.

import Foundation
import SystemConfiguration
import UIKit

struct Endpoint {
    //static let checkoutURL = "https://www.tecprocesssolution.com/proto/test/mobile/server/others/checkout.html"
    //static let banksConfigURL = "https://www.tecprocesssolution.com/proto/test/mobile/server/others/banksConfig.json"
    
    static let checkoutURL = "https://paynimo.com/paynimocheckout/server/others/checkout.html"
    static let banksConfigURL = "https://paynimo.com/paynimocheckout/server/others/banksConfig.json"
}
struct Message {
    static let backBtnMsg = "Are you sure you want to cancel the payment / request?"
    static let technicalFailMsg = "Due to some technical reason we are unable to process your request, please try again later!"
    static let internetFailMsg = "We are unable to process your request. Kindly check network connection."
    static let preloadMsg = "Kindly call preloadData() to initialize."
    static let deviceIDMsg = "Incorrect device identifier is passed, please use valid iOS device associated device identifiers like iOSSH1, iOSSH2."
    static let errorCheckoutMsg = "Payload data is not received."

}
struct HttpUtility {
    func getAPIData<T:Decodable>(requestUrl: URL, resultType: T.Type, completionHandler:@escaping(_ result : T) -> Void){
        let urlRequest = URLRequest(url: requestUrl)
        URLSession.shared.dataTask(with: urlRequest) {
            (responseData, httpUrlResponse, error) in
            if (error == nil && responseData != nil && responseData?.count != 0) {
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(T.self, from: responseData!)
                    _=completionHandler(response)
                }
                catch let error {
                    debugPrint("Error occured while decoding: \(error.localizedDescription)")
                }
            }
        }
        .resume()
    }
}
struct Reachability {
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
        else {
            return false
        }
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    func isInternetAvailable(completionHandler: @escaping (_ b: Bool) -> Void) {
        // 1. Check the WiFi Connection
        guard isConnectedToNetwork() else {
            completionHandler(false)
            return
        }
        // 2. Check the Internet Connection
        let webAddress = "https://www.google.com" // Default Web Site
        guard let url = URL(string: webAddress) else {
            completionHandler(false)
            //print("could not create url from: \(webAddress)")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) in
            if error != nil || response == nil {
                completionHandler(false)
            }
            else {
                completionHandler(true)
            }
        })
        task.resume()
    }
}
struct BankData: Decodable {
    let banksConfig: [BanksConfig]?
    enum CodingKeys: String, CodingKey {
        case banksConfig
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        banksConfig = try (values.decodeIfPresent([BanksConfig].self, forKey: .banksConfig))
    }
}
// MARK: - BanksConfig
struct BanksConfig: Decodable {
    let url: String
    let headerMeta, bodyData: String
    enum CodingKeys: String, CodingKey {
        case url
        case headerMeta
        case bodyData
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
        headerMeta = try values.decodeIfPresent(String.self, forKey: .headerMeta) ?? ""
        bodyData = try values.decodeIfPresent(String.self, forKey: .bodyData) ?? ""
    }
}
