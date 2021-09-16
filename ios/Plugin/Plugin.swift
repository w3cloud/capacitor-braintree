import Foundation
import Capacitor
import Braintree
import BraintreeDropIn

@objc(BraintreePlugin)
public class BraintreePlugin: CAPPlugin {
    
    var token: String!

    /**
     * Set Braintree API token
     * Set Braintree Switch URL
     */
    @objc func setToken(_ call: CAPPluginCall) {
        /**
         * Set App Switch
         */
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        BTAppSwitch.setReturnURLScheme("\(bundleIdentifier).payments")
        
        /**
         * Assign API token
         */
        self.token = call.hasOption("token") ? call.getString("token") : ""
        if self.token.isEmpty {
            call.reject("A token is required.")
            return
        }
        call.resolve()
    }
    
    /**
     * Show DropIn UI
     */
    @objc func showDropIn(_ call: CAPPluginCall) {
//        guard let amount = call.getString("amount") else {
//            call.reject("An amount is required.")
//            return;
//        }
        
        /**
         * DropIn UI Request
         */
        let request = BTDropInRequest()
        if call.hasOption("allowVaultCardOverride") {
            request.allowVaultCardOverride = call.getBool("allowVaultCardOverride") ?? false
        }
        if call.hasOption("applePayDisabled") {
            request.applePayDisabled = call.getBool("applePayDisabled") ?? false
        }
        if call.hasOption("cardDisabled") {
            request.cardDisabled = call.getBool("cardDisabled") ?? false
        }
        
        if call.hasOption("cardholderNameSetting") {
              if (call.getBool("cardholderNameSetting") ??  false){
                request.cardholderNameSetting = .required
            }
        }
        if call.hasOption("paypalDisabled") {
            request.paypalDisabled = call.getBool("paypalDisabled") ?? false
        }
        if call.hasOption("shouldMaskSecurityCode") {
            request.shouldMaskSecurityCode = call.getBool("shouldMaskSecurityCode") ?? false
        }
        if call.hasOption("vaultCard") {
            request.vaultCard=call.getBool("vaultCard") ?? false
        }
        if call.hasOption("vaultVenmo") {
            request.vaultVenmo = call.getBool("vaultVenmo") ?? false
        }
        if call.hasOption("venmoDisabled") {
            request.venmoDisabled=call.getBool("venmoDisabled") ?? false
            
        }
//        if call.hasOption("") {
//            request.=call.getBool("") ?? false
//        }
     
//        request.shouldMaskSecurityCode
//        request.vaultCard
//        request.vaultVenmo
//        request.venmoDisabled
//        request.threeDSecureRequest
//        request.threeDSecureVerification
//        let threeDSeciureRequest:BTThreeDSecureRequest=BTThreeDSecureRequest()
//        threeDSeciureRequest.challengeRequested
//        threeDSeciureRequest.amount
//        threeDSeciureRequest.email
//        threeDSeciureRequest.exemptionRequested
//        threeDSeciureRequest.mobilePhoneNumber
//        threeDSeciureRequest.nonce
//        threeDSeciureRequest.
//        request.threeDSecureRequest=threeDSeciureRequest
        
        
        /**
         * Disabble Payment Methods
         */
        /**
         * Initialize DropIn UI
         */
        let dropIn = BTDropInController(authorization: self.token, request: request)
        { (controller, result, error) in
            if (error != nil) {
                call.reject("Something went wrong.")
            } else if (result?.isCancelled == true) {
                call.resolve(["cancelled": true])
            } else if let result=result {
                print("result paymentDescription: ", result.paymentDescription)
                print("nonce: ", result.paymentMethod!.nonce)
                var response: [String: Any] = ["cancelled": false]
                response["nonce"]=result.paymentMethod!.nonce
                response["type"]=result.paymentMethod!.type
                call.resolve(response)
            }
            
            
            controller.dismiss(animated: true, completion: nil)
            
        }
        let cardForm=BTCardFormViewController(apiClient: dropIn!.apiClient, request: dropIn!.dropInRequest)
        cardForm.supportedCardTypes=[BTUIKPaymentOptionType.visa.rawValue as NSNumber]
     
        
        
        
        
//
//
//            NSString* token = [jsonData valueForKey:@"response"];
//                    self.req=[[BTDropInRequest alloc] init];
//
//                    self.req.applePayDisabled = YES ;
//
//                    self.cardForm = [[BTDropInController alloc] initWithAuthorization:token request:self.req handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
//
//
//
//                    }];
//
//                    BTCardFormViewController* vd = [[BTCardFormViewController alloc] initWithAPIClient:self.cardForm.apiClient request:self.cardForm.dropInRequest];
//                    vd.supportedCardTypes = [NSArray arrayWithObject:@(BTUIKPaymentOptionTypeVisa)];
//                    vd.delegate = self;
//
//                    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:vd];
//                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//                        navController.modalPresentationStyle = UIModalPresentationPageSheet;
//                    }
//
//                    [self presentViewController:navController animated:YES completion:nil];
//
        
        DispatchQueue.main.async {
            //dropIn?.showCardForm({})
            self.bridge?.viewController?.present(cardForm, animated: true, completion: nil)
        }
    }
    
    @objc func getPaymentMethodNonce(paymentMethodNonce: BTPaymentMethodNonce) -> [String:Any] {
        var payPalAccountNonce: BTPayPalAccountNonce
        var cardNonce: BTCardNonce
        var venmoAccountNonce: BTVenmoAccountNonce
        
        var response: [String: Any] = ["cancelled": false]
      

        response["nonce"] = paymentMethodNonce.nonce
        response["type"] = paymentMethodNonce.type
        response["localizedDescription"] = paymentMethodNonce.localizedDescription
        
        /**
         * Handle Paypal Response
         */
        if(paymentMethodNonce is BTPayPalAccountNonce){
            payPalAccountNonce = paymentMethodNonce as! BTPayPalAccountNonce
            response["paypal"] = [
                "email": payPalAccountNonce.email,
                "firstName": payPalAccountNonce.firstName,
                "lastName": payPalAccountNonce.lastName,
                "phone": payPalAccountNonce.phone,
                "clientMetadataId": payPalAccountNonce.clientMetadataId,
                "payerId": payPalAccountNonce.payerId
            ]
        }
        
        /**
         * Handle Card Response
         */
        if(paymentMethodNonce is BTCardNonce){
            cardNonce = paymentMethodNonce as! BTCardNonce
            response["card"] = [
                "lastTwo": cardNonce.lastFour,
                "network": cardNonce.cardNetwork
            ]
        }
        
        /**
         * Handle Card Response
         */
        if(paymentMethodNonce is BTVenmoAccountNonce){
            venmoAccountNonce = paymentMethodNonce as! BTVenmoAccountNonce
            response["venmo"] = [
                "username": venmoAccountNonce.username
            ]
        }
        
        return response;
        
    }
}
