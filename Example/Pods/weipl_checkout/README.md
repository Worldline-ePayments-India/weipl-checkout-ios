# iOS Checkout SDK for Worldline ePayments India.

This is official native SDK to integrate Worldline ePayments India Checkout.

[![CI Status](https://img.shields.io/travis/113965130/weipl_checkout.svg?style=flat)](https://travis-ci.org/113965130/weipl_checkout)[![Version](https://img.shields.io/cocoapods/v/weipl_checkout.svg?style=flat)](https://cocoapods.org/pods/weipl_checkout)[![License](https://img.shields.io/cocoapods/l/weipl_checkout.svg?style=flat)](https://cocoapods.org/pods/weipl_checkout)[![Platform](https://img.shields.io/cocoapods/p/weipl_checkout.svg?style=flat)](https://cocoapods.org/pods/weipl_checkout)

## Supported platforms

- iOS

**Note**:
- Make sure that you set project target for **Frameworks, Libraries, and Embedded Content** option should be **Embed & Sign**. 
- We support Xcode 12+ versions. 

## Integration code

Here is a checkout initialisation code sample:

```js
let reqJson : [String:Any] = [
    "features" : [
        "enableAbortResponse": true,
        "enableExpressPay": true,
        "enableInstrumentDeRegistration": true,
        "enableMerTxnDetails": true
    ],
    "consumerData": [
        "deviceId": "iOSSH2",    //possible values "iOSSH1" or "iOSSH2"
        "token": "0b125f92d967e06135a7179d2d0a3a12e246dc0ae2b00ff018ebabbe747a4b5e47b5eb7583ec29ca0bb668348e1e2cd065d60f323943b9130138efba0cf109a9",
        "paymentMode": "all",
        "merchantLogoUrl": "https://www.paynimo.com/CompanyDocs/company-logo-vertical.png",  //provided merchant logo will be displayed
        "merchantId": "L3348",
        "currency": "INR",
        "consumerId": "c964634",
        "consumerMobileNo": "9876543210",
        "consumerEmailId": "test@test.com",
        "txnId": "1665386045734",   //Unique merchant transaction ID
        "items": [[
            "itemId": "first",
            "amount": "10",
            "comAmt": "0"
        ]],
        "customStyle": [
            "PRIMARY_COLOR_CODE": "#45beaa",    // RGB and Hex and RGB supported parameter
            "SECONDARY_COLOR_CODE": "#ffffff",
            "BUTTON_COLOR_CODE_1": "#2d8c8c",
            "BUTTON_COLOR_CODE_2": "#ffffff",
        ]
    ]
]

do {
   let jSONObject = String(data: try JSONSerialization.data(withJSONObject: reqJson, options: .prettyPrinted), encoding: String.Encoding(rawValue: NSUTF8StringEncoding))
   WLCheckout!.open(requestObj: jSONObject!)
   DispatchQueue.main.async{
      self.present(self.WLCheckout!, animated: true, completion: nil)
   }
} catch _ as NSError {
   
}

@objc func wlCheckoutPaymentResponse(result: Notification) {
    print("\(result.object!)")
}

@objc func wlCheckoutPaymentError(result: Notification) {
    print("\(result.object!)")
}
```

### Complete Integration Guide

Please refer our integration guide for our **[iOS native SDK](https://www.paynimo.com/paynimocheckout/docs/?device=ios)**.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

weipl_checkout is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'weipl_checkout'
```

## Author

weipl-checkout-ios, ashish.palaskar@worldline.com

## License

weipl_checkout is available under the MIT license. See the LICENSE file for more info.

