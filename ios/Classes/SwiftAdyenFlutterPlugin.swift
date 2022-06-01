import Flutter
import UIKit
import Adyen
//import AdyenActions

public class SwiftAdyenFlutterPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "adyen_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftAdyenFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func encryptedCard(_ arguments: NSDictionary,completion: @escaping Completion<NSDictionary>) {
        do{
            let publicKeyToken = arguments["publicKeyToken"] as! String
            let cardNumberValue = arguments["cardNumber"] as! String
            let securityCodeValue = arguments["cardSecurityCode"] as! String
            let cardExpiryMonth = arguments["cardExpiryMonth"]  as! String
            let cardExpiryYear = arguments["cardExpiryYear"] as! String
            let expiryDate = cardExpiryMonth + cardExpiryYear
            let cardValidator = CardNumberValidator(isLuhnCheckEnabled:false,isEnteredBrandSupported:false)
            let isCardValid: Bool = cardValidator.isValid(cardNumberValue)
            let expiryValidator = CardExpiryDateValidator()
            let isExpiryValid: Bool = expiryValidator.isValid(expiryDate)
            let securityCodeValidator = CardSecurityCodeValidator()
            let isSecurityCodeValid = securityCodeValidator.isValid(securityCodeValue)
            if true{ //isCardValid && isExpiryValid && isSecurityCodeValid{
                print("Card is valid")
                let cardObject = Card(number: cardNumberValue, securityCode: securityCodeValue, expiryMonth: cardExpiryMonth, expiryYear: cardExpiryYear)
                let encryptedCard = try CardEncryptor.encrypt(card: cardObject, with: publicKeyToken)
                let dict = [
                                    "encryptedNumber":encryptedCard.number,
                                    "encryptedSecurityCode":encryptedCard.securityCode,
                                    "encryptedExpiryMonth":encryptedCard.expiryMonth,
                                    "encryptedExpiryYear":encryptedCard.expiryYear
                                ]
                completion(dict as NSDictionary)
            }
            else{
            completion([:] as NSDictionary)
            }
        } catch {
        print(error)
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch (call.method) {
        case "encryptedCard":
            encryptedCard(arguments!) { (encryptedCard) in
                result(encryptedCard)
            }
        default:
            result(FlutterMethodNotImplemented)
            
        }
    }

    
}
