//
//  ViewController.swift
//  weipl_checkout
//
//  Created by 113965130 on 02/03/2023.
//  Copyright (c) 2023 113965130. All rights reserved.
//

import UIKit
import weipl_checkout
import Stripe

extension Date {
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        return dateFormatter.string(from: Date())
    }

}

class ViewController: UIViewController {

    var WLCheckout : WLCheckoutViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.wlCheckoutPaymentResponse(result:)), name: Notification.Name("wlCheckoutPaymentResponse"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.wlCheckoutPaymentError(result:)), name: Notification.Name("wlCheckoutPaymentError"), object: nil)
        
        WLCheckout = WLCheckoutViewController()
        WLCheckout?.preloadData()
    }

    @IBAction func paymentbtn(_ sender: Any) {
        
        let checkoutPayload : [String:Any] = [
            "liveApiCall": true, // inside SDK ToDo : need to be removed before prod live
            //"hybridCheckout" : false, // inside SDK ToDo : Handeling need to be done for internal sdk validation
            "decryptedResponse" : true,
            "debugger" : false, // print logs against webview activities
            "features" : [
                "showLoader": true,
                "showPGResponseMsg": false, // inside SDK ToDo : Handeling by default true value for not showing payment receipt
                "enableExpressPay": false,
                "showDownloadReceipt": false,
                "payDetailsAtMerchantEnd" : false,
                "payWithSavedInstrument" : false,
                "enableAbortResponse": true,
                "enableMerTxnDetails": true,
                "hideSavedInstruments": false,
                "enableInstrumentDeRegistration": false,
                "enableSI" : false,
                "separateCardMode": false,
                "enableUPISplittedView" : true
            ],
            "consumerData": [
                "deviceId": "iOSweb", // iOSweb/iOSSH1/iOSSH2/iOSMD5/iOSDIRECTSH1/iOSDIRECTSH2/iOSDIRECTMD5
                "token": "fa7d0b29ae78f5aafb86068591d26fe93ac2e1dfd115e076494f7bc954b4939a",
                "paymentMode": "all",
                "merchantLogoUrl": "",
                "merchantId": "L3348",//merchantIdTF.text!,
                "currency": "INR",//currencyTF.text!,
                "consumerId": "1242525629528569",//consumerIdTF.text!,
                "consumerMobileNo": "9136541011",//mobileNumberTF.text!,
                "consumerEmailId": "ashu548@yahoo.com",//consumerEmailTF.text!,
                // "accountNo": "",
                "txnId": Date.getCurrentDate(),
                "items": [[
                    "itemId": "test",//itemIdTF.text!,
                    "amount": "1",//amountTF.text!,
                    "comAmt": "0"
                ]],
                "customStyle": [
                    "PRIMARY_COLOR_CODE": "#45beaa", // RGB and Hex and RGB supported parameter
                    "SECONDARY_COLOR_CODE": "#ffffff",
                    "BUTTON_COLOR_CODE_1": "#2d8c8c",
                    "BUTTON_COLOR_CODE_2": "#ffffff",
                ]
            ]
        ];
        
        do {
            
            let jSONObject = String(data: try JSONSerialization.data(withJSONObject: checkoutPayload, options: .prettyPrinted), encoding: String.Encoding(rawValue: NSUTF8StringEncoding))
            
            print(jSONObject!)
            
            WLCheckout!.open(requestObj: jSONObject!)
            
            DispatchQueue.main.async{
                
                self.present(self.WLCheckout!, animated: true, completion: nil)
            }
        } catch _ as NSError {

        }
        
    }
    
    // TODO : Explaination of this method needs to be added in documentation
    @objc func wlCheckoutPaymentResponse(result: Notification) {
        
        print("\(result.object!)")
        
         DispatchQueue.main.async{
         
         // create the alert
         let alert = UIAlertController(title: "WLCheckout", message: "\(result.object!)", preferredStyle: UIAlertController.Style.alert)
         // add an action (button)
         // show the alert
         alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
         print("Handle Ok logic here")
         
         }))
         
         self.present(alert, animated: true, completion: nil)
         }
    }
    
    @objc func wlCheckoutPaymentError(result: Notification) {
        
        print("\(result.object!)")
        
         DispatchQueue.main.async{
         
         // create the alert
         let alert = UIAlertController(title: "WLCheckout", message: "\(result.object!)", preferredStyle: UIAlertController.Style.alert)
         // add an action (button)
         // show the alert
         alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
         print("Handle Ok logic here")
         
         }))
         
         self.present(alert, animated: true, completion: nil)
         }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

