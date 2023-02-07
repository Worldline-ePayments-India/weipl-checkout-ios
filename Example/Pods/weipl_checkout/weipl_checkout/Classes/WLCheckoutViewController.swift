// CheckoutViewController.swift
// weipl_checkout
// Created by Wordline ePayments India on 05/10/2022
// Copyright © 2022 Wordline ePayments India. All rights reserved.

import Foundation
import WebKit
import UIKit
import CallKit
import SwiftUI

public class WLCheckoutViewController: UIViewController , WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler,
                                     CXCallObserverDelegate {
    
    @IBOutlet weak var TopNavigationBar: UIView!
    @IBOutlet weak var TopNavigationBarHeight: NSLayoutConstraint!
    @IBOutlet weak var WebViewTopHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webContainerCompactView: UIView!
    
    var requestDict : Dictionary<String, Any>?
    var TARoptions : Dictionary<String, Any>?
    var didDetectOutgoingCall = false
    var functionname : String?
    var success : String?
    var error : String?
    var args : NSArray?
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var timer = Timer()
    var preLoadTimer = Timer()
    var newDate : String?
    var bankConfigUrlArray = [String]()
    var bankConfigHeaderMetaArray = [String]()
    var bankConfigBodyDataArray = [String]()
    var isCheckoutLoad = false
    var TARcall = false
    var decryptedResponse = false
    var TARdictionary = [String:String]()
    var deviceID : String = ""
    var PRIMARY_COLOR_CODE = ""
    
    var counterOnlineStatus : Int
    var failedToloadCheckout : Bool
    var preloadDataStatus : Bool
    
    private let httpUtility = HttpUtility()
    private let reachability = Reachability()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.newDate = Date.getCurrentDate()
        self.counterOnlineStatus = 0
        self.failedToloadCheckout = false
        self.preloadDataStatus = false
        
        // White screen issue in second time pay action from simulator.
        super.init(nibName: "WLCheckoutViewController", bundle: Bundle(for: WLCheckoutViewController.self))
        self.modalPresentationStyle = .fullScreen
    }
    /**
     * This is used to preload initial details for optimized user experience.
     */
    public func preloadData() {
        preloadDataStatus = true
        DispatchQueue.main.async{
            self.modalPresentationStyle = .currentContext
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: nil)
            self.dismiss(animated: false) //NOTE : dismiss SDK view once preload called.
        }
        self.preLoadTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.preInitialize), userInfo: nil, repeats: false)
    }
    /**
     * This is used to invoke WEIPL Checkout SDK
     * @param context current activity Context
     * @param options JSONObject for Checkout invocation
     */
    public func open(requestObj: String) {
        view.isHidden = false
        let status = reachability.isConnectedToNetwork()
        
        if(!status && !failedToloadCheckout) {
            let item: [String: Any] = [
                "error_code": "0399",
                "error_desc": Message.internetFailMsg]
            let jsonData = try! JSONSerialization.data(withJSONObject: item, options: JSONSerialization.WritingOptions.prettyPrinted)
            let response = String(data: jsonData, encoding: String.Encoding.utf8)!
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name("wlCheckoutPaymentError"), object: "\(response)")
            })
            return
        }
        if (!preloadDataStatus) {
            let item: [String: Any] = [
                "error_code": "0399",
                "error_desc": Message.preloadMsg]
            let jsonData = try! JSONSerialization.data(withJSONObject: item, options: JSONSerialization.WritingOptions.prettyPrinted)
            let response = String(data: jsonData, encoding: String.Encoding.utf8)!
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name("wlCheckoutPaymentError"), object: "\(response)")
            })
            return
        }
        
        requestDict = requestObj.toJSON() as? Dictionary<String, Any>
        let consumerDataDict = requestDict!["consumerData"] as Any
        let dict = consumerDataDict as? [String:Any] // can be any type here
        let customStyleDict = dict!["customStyle"] as Any
        let deviceID = dict!["deviceId"] as! String
        let dictfinal = customStyleDict as? [String:Any] // can be any type here
        PRIMARY_COLOR_CODE = dictfinal!["PRIMARY_COLOR_CODE"] as! String
        // NOTE : Restrict nil consumerData param
        if(requestDict!["consumerData"] == nil) {
            
            let item: [String: Any] = [
                "error_code": "0399",
                "error_desc": Message.errorCheckoutMsg]
            let jsonData = try! JSONSerialization.data(withJSONObject: item, options: JSONSerialization.WritingOptions.prettyPrinted)
            let response = String(data: jsonData, encoding: String.Encoding.utf8)!
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name("wlCheckoutPaymentError"), object: "\(response)")
            })
            return
        }
        // NOTE : Restrict wrong device ID's
        if (!deviceID.containsIgnoringCase(find: "ios")) {
            let item: [String: Any] = [
                "error_code": "0399",
                "error_desc": Message.deviceIDMsg]
            let jsonData = try! JSONSerialization.data(withJSONObject: item, options: JSONSerialization.WritingOptions.prettyPrinted)
            let response = String(data: jsonData, encoding: String.Encoding.utf8)!
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name("wlCheckoutPaymentError"), object: "\(response)")
            })
            return
        }
        // NOTE : Restrict nil decryptedResponse param
        if (requestDict!["decryptedResponse"] != nil) {
            self.decryptedResponse = requestDict!["decryptedResponse"] as! Bool
        }
        else {
            self.decryptedResponse = false
        }
        // NOTE : Restrict nil hybridCheckout param and set default value to True
        if (requestDict!["hybridCheckout"] != nil) {
            self.requestDict!.updateValue(true, forKey: "hybridCheckout")
        }
        else {
            let item: [String: Any] = [
                "hybridCheckout": true,]
            self.requestDict!.append(anotherDict: item)
        }
        if (failedToloadCheckout || !isCheckoutLoad) {
            self.preInitialize() // proper validation
        }
        else {
            self.isCheckoutLoad = true
            self.pageLoadFinish()
        }
    }
    
    public func initiateCheckoutJS() {
        self.isCheckoutLoad = true
        DispatchQueue.main.async{
            let request = URLRequest(url: URL(string: Endpoint.checkoutURL+"?v"+self.newDate!)!) // No need to clear cache from webview.
            self.webView?.load(request)
        }
    }
    
    @IBAction func preInitialize() {
        initiateCheckoutJS()
        getBankConfigMethod()
        withoutNavigationBar()
        preLoadTimer.invalidate()
    }
    
    @objc func invokeWebView(){
        webView.uiDelegate = self
        webView.scrollView.delegate = self // Set WKWebView ScrollView delegate.
        webView.scrollView.bounces = false // Set WKWebView Bounce property.
        webView.uiDelegate = self // Set WKWebView UI Delegate
        webView.navigationDelegate = self // set WKWebView navigationDelegate.
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView.cleanAllCookies()
        webView.refreshCookies()
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "responseHandler") // JS method
        contentController.add(self, name: "checkInstalledUpiApp") // JS check installed UPI applications
        contentController.add(self, name: "invokeUpiIntentApp") // JS invoke UPI intent applications
        contentController.add(self, name: "isOnline") // JS check installed UPI applications
        
    }
    
    func pageLoadFinish() {
        DispatchQueue.main.async {
            let string = self.PRIMARY_COLOR_CODE
            if let hexValue = UInt(string.suffix(6), radix: 16) {
                // create the color from hexValue
                self.webContainerCompactView.backgroundColor = self.UIColorFromHex(rgbValue: UInt32(hexValue), alpha: 1.0)
            }
            if(self.isCheckoutLoad){
                var RequestDict : Dictionary<String, Any>?
                if (self.TARcall) {
                    RequestDict = self.TARoptions
                }
                else {
                    RequestDict = self.requestDict
                }
                if RequestDict != nil {
                    self.loadCheckout(arg: RequestDict!)
                }
                self.isCheckoutLoad = false
                self.withoutNavigationBar() // Without TopBar
                self.failedToloadCheckout = false
            }
            else {
                self.withNavigationBar() // With TopBar
            }
        }
    }
    
    func getBankConfigMethod() {
        let banksConfigURL = URL(string: Endpoint.banksConfigURL)!
        // GET API method - bank configured data
        httpUtility.getAPIData(requestUrl: banksConfigURL, resultType: BankData.self) {
            (getBankConfigResult) in
            DispatchQueue.main.async {
                self.bankConfigUrlArray.removeAll()
                self.bankConfigHeaderMetaArray.removeAll()
                self.bankConfigBodyDataArray.removeAll()
                for x in 0...getBankConfigResult.banksConfig!.count-1 {
                    self.bankConfigUrlArray.append(getBankConfigResult.banksConfig![x].url)
                    self.bankConfigHeaderMetaArray.append(getBankConfigResult.banksConfig![x].headerMeta)
                    self.bankConfigBodyDataArray.append(getBankConfigResult.banksConfig![x].bodyData)
                }
            }
        }
    }
    
    func loadCheckout(arg : Dictionary<String, Any>) {
        // Conversion from merchant request bidy to Json String.
        let jsonData = try! JSONSerialization.data(withJSONObject: arg, options: JSONSerialization.WritingOptions.prettyPrinted)
        let decoded = String(data: jsonData, encoding: String.Encoding.utf8)!
        let scriptSource = "loadCheckout(\(decoded))"
        webView.evaluateJavaScript(scriptSource) {
            (result, error) in
            if result != nil {
                //print("evaluateJavaScript Resposne : \(result!)")
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // Without this, it'll crash when your MyClass instance is deinit'd
        webView?.scrollView.delegate = nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.invokeWebView()
    }
    
    func withNavigationBar() {
        WebViewTopHeight.constant = 54.0
        TopNavigationBarHeight.constant = 54.0
        TopNavigationBar.isHidden = false
        webContainerCompactView.isHidden = false
        webContainerCompactView.addSubview(webView)
    }
    
    func withoutNavigationBar() {
        WebViewTopHeight.constant = 0
        TopNavigationBarHeight.constant = 0
        TopNavigationBar.isHidden = true
        webContainerCompactView.addSubview(webView)
    }
    
    //NOTE : Bank page Back action
    @IBAction func closeBtn(_ sender: Any) {
        DispatchQueue.main.async{
            // create the alert
            let alert = UIAlertController(title: "Confirmation", message: "\(Message.backBtnMsg)", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {
                (action: UIAlertAction!) in
            }))
            // show the alert
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                self.TopNavigationBar.isHidden = true
                self.initiateCheckoutJS()
                self.withoutNavigationBar()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func callTARRequest(sender: UIButton) {
        initiateCheckoutJS()
        timer.invalidate()
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    public func checkInstalledUpiApp(scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        else {
            return false
        }
    }
    
    public func invokeUpiIntentApp(message: WKScriptMessage){
        
        DispatchQueue.main.async {
            
            let callObserver = CXCallObserver()
            let jsonData = message.body as? [String:Any] // can be any type here
            let uri = jsonData?["uri"] as! String
            let callback = jsonData?["callback"] as! String
            guard let urlString = uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else {
                return
            }
            guard let url = URL(string: urlString) else {
                return
            }

            if !UIApplication.shared.canOpenURL(url) {
                return
            }
            callObserver.setDelegate(self, queue: nil)
            self.didDetectOutgoingCall = false
            UIApplication.shared.open(url, options: [:], completionHandler: {
                (success) in
                let scriptSource = "\(callback)(\(true))"
                self.webView.evaluateJavaScript(scriptSource) {
                    (result, error) in
                    if result != nil {
                        if success {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.addNotifObserver()
                            }
                        }
                    }
                }
            })
        }
    }
    
    func isOnline() -> Bool {
        
        let status = reachability.isConnectedToNetwork()
        return status
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    // LAST STEP
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Final PG response
        if message.name == "responseHandler" {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {
                    let hybridCheckoutRes = self.requestDict!["consumerData"] as Any
                    let dict = hybridCheckoutRes as? [String:Any] // can be any type here
                    self.deviceID = (dict?["deviceId"] as! String).lowercased()
                    let jsonData = try! JSONSerialization.data(withJSONObject: message.body, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let response = String(data: jsonData, encoding: String.Encoding.utf8)!
                    if (self.decryptedResponse == true && (self.deviceID == "iosweb" || self.deviceID == "ios")) {
                        // Call back handeling for decrypted response i.e message.body
                        NotificationCenter.default.post(name: Notification.Name("wlCheckoutPaymentResponse"), object: "\(response)")
                    }
                    else {
                        // Call back handeling for encrypted response i.e message.body.merchantResponseString (close / cancel / back event)
                        NotificationCenter.default.post(name: Notification.Name("wlCheckoutPaymentResponse"), object: "\(response)")
                    }
                })
            }
        }
        else if message.name == "checkInstalledUpiApp" {
            DispatchQueue.main.async {
                do{
                    let jsonData = message.body as? [String:Any] // can be any type here
                    let scheme = jsonData?["scheme"] as! String
                    let callback = jsonData?["callback"] as! String
                    let result = self.checkInstalledUpiApp(scheme: scheme) // schemes from message.body
                    var RequestDict : Dictionary<String, Any>?
                    RequestDict = ["scheme":scheme, "isInstalled":result]
                    // Retrive Key from Result
                    let data = try JSONSerialization.data(withJSONObject: RequestDict!) // convert json format
                    let dataString = String(data: data, encoding: .utf8)!
                    let scriptSource = "\(callback)(\(dataString))" // append data to share with JS method.
                    self.webView.evaluateJavaScript(scriptSource) {
                        (result, error) in
                        if result != nil {
                            //print("evaluateJavaScript Resposne : \(result!)")
                        }
                    }
                }
                catch{
                    // do nothing
                }
            }
        }
        else if message.name == "invokeUpiIntentApp"{
            self.invokeUpiIntentApp(message: message)
        }
        else if message.name == "isOnline"{
            // response from JS in case
        }
        else {
            // do nothing
        }
    }
    
    func addNotifObserver() {
        let selector = #selector(appDidBecomeActive)
        let notifName = UIApplication.didBecomeActiveNotification
        NotificationCenter.default.addObserver(self, selector: selector, name: notifName, object: nil)
    }
    
    @objc func appDidBecomeActive() {
        //if callObserver(_:callChanged:) doesn't get called after a certain time,
        //the call dialog was not shown - so the Cancel button was pressed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            [weak self] in
            if !(self?.didDetectOutgoingCall ?? true) {
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //DLog(message: "didFail navigation \(String(describing: webView.url?.absoluteString))")
        self.pageLoadFinish()
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        //DLog(message: "runJavaScriptAlertPanelWithMessage \(message.description)")
        let alertController = UIAlertController(title: message,message: nil,preferredStyle:
                .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) {
            _ in
            completionHandler()
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        let httpResponse = navigationResponse.response as? HTTPURLResponse
        
        if navigationResponse.response is HTTPURLResponse {
            
            if ((String(describing: navigationResponse.response.url?.absoluteString) .contains("\(Endpoint.checkoutURL)")) &&
                !(200..<400).contains(httpResponse!.statusCode)) {
                failedToloadCheckout = true
                if (self.counterOnlineStatus == 0) {
                    self.counterOnlineStatus = self.counterOnlineStatus + 1
                }
                else if (self.counterOnlineStatus >= 1) {
                    let item: [String: Any] = [
                        "error_code": "0399",
                        "error_desc": Message.technicalFailMsg]
                    let jsonData = try! JSONSerialization.data(withJSONObject: item, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let response = String(data: jsonData, encoding: String.Encoding.utf8)!
                    self.dismiss(animated: false, completion: {
                        NotificationCenter.default.post(name: Notification.Name("wlCheckoutPaymentError"), object: "\(response)")
                    })
                }
            }
            else {
                // do nothing
            }
            
        }
        decisionHandler(.allow)
    }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if let url = navigationAction.request.url, !url.absoluteString.hasPrefix("js2ios://?") {
                UIApplication.shared.canOpenURL(url)
                if !(navigationAction.targetFrame == nil) {
                    self.webView?.load(navigationAction.request)
                }
                else {
                    UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }
        default:
            break
        }
        if let url = navigationAction.request.url {
            var urlStr = webView.url?.absoluteString
            let protocolPrefix = "js2ios://?"
            if (url.absoluteString.hasPrefix(protocolPrefix)) {
                urlStr = NSString(string: url.absoluteString).removingPercentEncoding!
                urlStr = urlStr?.removingPercentEncoding!
                urlStr = urlStr?.replacingOccurrences(of: protocolPrefix, with: "", options: [.caseInsensitive])
                let dict = urlStr!.toJSON() as! [String:AnyObject]
                functionname = (dict["functionname"] as! String)
                success = (dict["success"] as! String)
                error = (dict["error"] as! String)
                args = (dict["args"] as! NSArray)
                var argsArray : [String] = []
                if (self.decryptedResponse == true && (self.deviceID == "iosweb" || self.deviceID == "ios")) {
                    argsArray.append(((args![0] as AnyObject).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!))
                    argsArray.append((args![1]) as! String)
                }
                else {
                    argsArray = args as! [String]
                }
                callFunction(name: functionname!, args: [argsArray as Any] as NSArray, completionBlockSuccess: {
                    (success) -> Void in
                    // your successful handle
                })
                {
                    (failure) -> Void in
                    // your failure handle
                }
            }
        }
        decisionHandler(.allow)
    }
    // Remove public from here
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        if let err = error as? URLError {
            if ((String(describing: err.errorUserInfo.values) .contains("\(Endpoint.checkoutURL)"))) {
                self.counterOnlineStatus = 1
                self.failedToloadCheckout = true
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //DLog(message: "didCommit \(String(describing: webView.url?.absoluteString))")
        if let url = webView.url?.absoluteURL {
            let searchString = url.absoluteString
            let result = self.bankConfigUrlArray.contains(where: searchString.contains)
            if let i = self.bankConfigUrlArray.firstIndex(where: searchString.contains) {
                if result {
                    if (!self.bankConfigHeaderMetaArray[i].isEmpty )
                    {
                        // Header value manipulation.
                        let jsString = "document.getElementsByTagName(\"head\")[0].insertAdjacentHTML(\"beforeend\", \"\(self.bankConfigHeaderMetaArray[i])\");"
                        DispatchQueue.main.async {
                            webView.evaluateJavaScript(jsString) {
                                (result, error) in
                                if result != nil {
                                    //print("evaluateJavaScript Resposne : \(result!)")
                                }
                            }
                        }
                    }
                    if (!self.bankConfigBodyDataArray[i].isEmpty ){
                        webView.evaluateJavaScript((self.bankConfigBodyDataArray[i])) {
                            (result, error) in
                            if result != nil {
                                //print("evaluateJavaScript Resposne : \(result!)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func callFunction (name: String, args: NSArray, completionBlockSuccess aBlock: ((AnyObject) -> Void), andFailureBlock failBlock: ((AnyObject) -> Void)) {
        let val : String? = processFunctionFromJS(name: functionname!, args: args)
        callSuccessCallback(name: success!, retValue: val!, funcName: functionname!)
    }
    
    func performRequestWithServiceName(name: String, args: NSArray, success successBlock: ((AnyObject) -> Void), failure failureBlock: ((AnyObject) -> Void)) {
        // do nothing
    }
    
    func processFunctionFromJS(name: String, args: NSArray) -> String? {
        let result: ComparisonResult = name.compare("setTER", options: NSString.CompareOptions.caseInsensitive)
        if result == .orderedSame {
            if args.count > 0 {
                let arrFiltered:NSMutableArray! = []
                for arr in args {
                    for a in arr as! NSArray {
                        arrFiltered.add(a)
                    }
                }
                TARdictionary = [String:String]()
                let hybridCheckoutRes = self.requestDict!["consumerData"] as Any
                let dict = hybridCheckoutRes as? [String:Any] // can be any type here
                self.deviceID = (dict?["deviceId"] as! String).lowercased()
                if (self.deviceID == "iosweb" || self.deviceID == "ios") {
                    // json response format
                    TARdictionary["txthdnMsg"] = arrFiltered[0] as? String
                    TARdictionary["txthdntpslmrctcd"] = arrFiltered[1] as? String
                }
                else if (self.deviceID == "iossh1" || self.deviceID == "iossh2" || self.deviceID == "iosmd5") {
                    // json response format
                    TARdictionary["msg"] = arrFiltered[0] as? String
                }
                else if (self.deviceID == "iosdirectsh1" || self.deviceID == "iosdirectsh2" || self.deviceID == "iosdirectmd5"){
                    // json response format
                    TARdictionary["msg"] = arrFiltered[0] as? String
                    TARdictionary["tpsl_mrct_cd"] = arrFiltered[1] as? String
                }
                else {
                    //Other resposne future value (iOSJSON - DeviceID)
                    TARdictionary["data"] = arrFiltered[0] as? String
                }
                return arrFiltered[0] as? String
            }
            return nil;
        }
        else {
            return nil;
        }
    }
    
    func callSuccessCallback(name: String, retValue: String, funcName: String) -> Void {
        var dictionary = [String:String]()
        dictionary["result"] = retValue
        callJSFunction(name: success!, args: dictionary)
    }
    
    func callJSFunction(name: String, args: Dictionary<String, Any>) -> Void {
        DispatchQueue.main.async {
            do {
                // Retrive Key from Result
                let data = try JSONSerialization.data(withJSONObject: args)
                let dataString = String(data: data, encoding: .utf8)!
                let resultDict = dataString.toJSON() as? [String:AnyObject] // can be any type here
                let consumerData = self.requestDict!["consumerData"] as Any
                var consumerDataDict = consumerData as! [String:Any] // can be any type here
                self.deviceID = (consumerDataDict["deviceId"] as! String).lowercased() // Lower case Device ID
                // With TAR option true need to provide decripted response to merchant.
                if (self.decryptedResponse == true && (self.deviceID == "iosweb" || self.deviceID == "ios")) {
                    self.TARoptions = self.requestDict
                    let MIDRetrived = self.TARdictionary["txthdntpslmrctcd"]!
                    let KeyRetrived = (resultDict!["result"] as! String)
                    let tarCall : Bool = true
                    consumerDataDict.append(anotherDict: ["desc":KeyRetrived])
                    consumerDataDict.append(anotherDict: ["merchantId":MIDRetrived])
                    self.TARoptions!.updateValue(tarCall, forKey: "tarCall")
                    self.TARoptions!.append(anotherDict: ["consumerData":consumerDataDict as Any])
                    // Retrive Key from Result
                    let data = try JSONSerialization.data(withJSONObject: self.TARoptions as Any)
                    let dataString = String(data: data, encoding: .utf8)!
                    self.TARoptions = dataString.toJSON() as? Dictionary<String, Any>
                    self.TARcall = true
                    self.timer.invalidate() // just in case this button is tapped multiple times
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.callTARRequest), userInfo: nil, repeats: false)
                }
                else {
                    self.TARoptions = resultDict
                    let MIDRetrived = consumerDataDict["merchantId"]
                    let item: [String: Any] = [
                        "merchant_code": MIDRetrived!]
                    if (self.TARdictionary["tpsl_mrct_cd"] == nil) {
                        self.TARoptions!.append(anotherDict: item)
                    }
                    else {
                        // do nothing
                    }
                    let jsonData = try! JSONSerialization.data(withJSONObject: self.TARoptions as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let response = String(data: jsonData, encoding: String.Encoding.utf8)!
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: Notification.Name("wlCheckoutPaymentResponse"), object: "\(response)")
                    })
                }
            }
            catch {
                //print("JSON serialization failed: ", error)
            }
        }
    }
    
    public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.isOutgoing && !didDetectOutgoingCall {
            didDetectOutgoingCall = true
        }
    }
    
}
