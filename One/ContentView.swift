import SwiftUI
import PassKit
import FirebaseFirestore

// UIViewControllerRepresentable to wrap the Apple Pay ViewController
struct ApplePayViewControllerRepresentable: UIViewControllerRepresentable {
    var paymentRequest: PKPaymentRequest
    var onPaymentSuccess: () -> Void
    var onPaymentFailure: () -> Void
    
    class Coordinator: NSObject, PKPaymentAuthorizationViewControllerDelegate {
        var parent: ApplePayViewControllerRepresentable
        
        init(parent: ApplePayViewControllerRepresentable) {
            self.parent = parent
        }

        // Called when payment is authorized
        func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
            // Log the authorization and payment details
            print("Payment authorized with token: \(payment.token)")
            print("Payment details: \(payment.token.paymentData)")
            
            // Simulate success for now
            completion(.success)
            print("Payment authorization completed successfully")
            
            // Notify the parent about the success
            parent.onPaymentSuccess()
        }
        
        // Called when the payment process finishes
        func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
            // Log that the payment authorization view is finished
            print("Payment authorization view finished.")
            controller.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PKPaymentAuthorizationViewController {
        return PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)!
    }
    
    func updateUIViewController(_ uiViewController: PKPaymentAuthorizationViewController, context: Context) {
        // No update needed for this simple case
    }
}

struct ContentView: View {
    @State private var isPaymentSuccessful = false
    @State private var applePayPresented = false  // State to control showing Apple Pay

    var body: some View {
        VStack {
            if isPaymentSuccessful {
                Text("Payment was successful!")
                    .foregroundColor(.green)
            } else {
                Button("Pay with Apple Pay") {
                    startApplePayPayment()
                }
                .padding()
            }
        }
        .onAppear {
            // Ensure Apple Pay is available
            if !PKPaymentAuthorizationViewController.canMakePayments() {
                print("Apple Pay is not available on this device")
            }
        }
        .sheet(isPresented: $applePayPresented) {
            // Safely unwrap the payment request before passing it to the ViewController
            if let paymentRequest = createApplePayRequest() {
                ApplePayViewControllerRepresentable(
                    paymentRequest: paymentRequest,
                    onPaymentSuccess: {
                        self.isPaymentSuccessful = true
                        self.applePayPresented = false
                        print("Payment was successful!")
                    },
                    onPaymentFailure: {
                        print("Payment failed.")
                        self.applePayPresented = false
                    })
            }
        }
    }
    
    // Creates a payment request and starts the Apple Pay flow
    func startApplePayPayment() {
        guard let paymentRequest = createApplePayRequest() else {
            print("Error creating payment request.")
            return
        }

        // Log the request before presenting
        print("Presenting Apple Pay with request: \(paymentRequest)")

        // Show the Apple Pay screen
        applePayPresented = true
    }
    
    // Creates the Apple Pay payment request
    func createApplePayRequest() -> PKPaymentRequest? {
        guard PKPaymentAuthorizationViewController.canMakePayments() else {
            print("Apple Pay is not available on this device.")
            return nil
        }
        
        let paymentRequest = PKPaymentRequest()
        
        // Set the merchant identifier (replace with your actual Merchant ID)
        paymentRequest.merchantIdentifier = "merchant.treylee.One"
        
        // Set supported networks
        paymentRequest.supportedNetworks = [.visa, .masterCard]
        
        // Set merchant capabilities (3D Secure for extra authentication)
        paymentRequest.merchantCapabilities = .threeDSecure  // Replaced 'capability3DS' with 'threeDSecure'
        
        // Set the country and currency code
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        
        // Define the payment summary items
        let totalAmount = NSDecimalNumber(string: "3.99")
        let paymentSummaryItem = PKPaymentSummaryItem(label: "Product Name", amount: totalAmount)
        
        paymentRequest.paymentSummaryItems = [paymentSummaryItem]
        
        // Log the created payment request
        print("Created Apple Pay request: \(paymentRequest)")
        
        return paymentRequest
    }
}

#Preview {
    ContentView()
}
