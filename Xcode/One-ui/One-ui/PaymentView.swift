import SwiftUI
import StripeCore
import StripePaymentSheet
import PassKit

struct PaymentView: View {
    @State private var isProcessingPayment = false
    @State private var paymentSheet: PaymentSheet?
    
    var body: some View {
        VStack {
            if isProcessingPayment {
                ProgressView("Processing...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button("Pay with Apple Pay") {
                    startApplePay()
                }
                .padding()
            }
        }
        .onAppear {
            // Initialize Stripe publishable key only when the view appears
            StripeAPI.defaultPublishableKey = "pk_test_51QLo6WBsR5frtF6syrD7xI8NcdzPmqSqLsoPQjQPrgFHIPN1jD2m5EyPwVYgVNvwRHka5i9HYXfeagUv3gIicxFV00WDdP65OQ"
        }
    }
    
    func startApplePay() {
        // Step 1: Check if the device can make Apple Pay payments
        print("✅ Checking if device can make Apple Pay payments...")
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.visa, .masterCard, .amex]) else {
            print("❌ Apple Pay is not available on this device. Please make sure the device supports Apple Pay.")
            return
        }
        
        // Step 2: Request a Payment Intent from your backend with amount info
        print("🔄 Fetching Payment Intent from backend...")
        fetchPaymentIntentFromBackend { clientSecret, amount in
            print("✅ Received client secret from backend: \(clientSecret)")
            
            // Step 3: Create PaymentSheet with the clientSecret and Apple Pay as a payment method
            var configuration = PaymentSheet.Configuration()
            
            // Set the Apple Pay configuration
            configuration.applePay = .init(
                merchantId: "merchant.treylee.one-ui", merchantCountryCode: "US" // Your Apple Merchant ID
            )
            
            let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
            self.paymentSheet = paymentSheet
            
            // Step 4: Present PaymentSheet
            DispatchQueue.main.async {
                print("🔲 Presenting PaymentSheet...")
                self.isProcessingPayment = true // Show loading indicator
                paymentSheet.present(from: UIApplication.shared.windows.first!.rootViewController!) { paymentResult in
                    self.isProcessingPayment = false // Hide loading indicator after payment result

                    switch paymentResult {
                    case .completed:
                        print("✅ Payment completed successfully!")
                        // Optionally, you can send the amount or perform additional actions here
                    case .canceled:
                        print("🚫 Payment was canceled by the user.")
                    case .failed(let error):
                        print("❌ Payment failed with error: \(error.localizedDescription)")
                        logPaymentError(error)
                    }
                }
            }
        }
    }
    
    func fetchPaymentIntentFromBackend(completion: @escaping (String, Int) -> Void) {
        guard let url = URL(string: "https://c9b5-173-94-62-99.ngrok-free.app/create-payment-intent") else {
            print("❌ Invalid URL for backend API.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Define the amount in cents
        let amount = 1000 // Amount in cents
        let body: [String: Any] = ["amount": amount, "currency": "usd"]
        print("🔄 Sending request to backend with data: \(body)")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching payment intent: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received from backend.")
                return
            }
            
            // Log the raw response data (this helps you debug the response from the backend)
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("🔄 Backend Response: \(rawResponse)")
            }

            // Try to parse the JSON response
            if let responseJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("✅ Successfully parsed JSON response: \(responseJson)")
                
                if let clientSecret = responseJson["clientSecret"] as? String {
                    // Call the completion handler with the client secret and amount
                    completion(clientSecret, amount)
                } else {
                    print("❌ Client secret not found in the response.")
                }
            } else {
                print("❌ Error parsing backend response.")
            }
        }
        
        task.resume()
    }
    
    func logPaymentError(_ error: Error) {
        print("💥 Payment error details:")
        print("Error: \(error.localizedDescription)")

        if let nsError = error as NSError? {
            print("Error Code: \(nsError.code)")
            print("Error Domain: \(nsError.domain)")
        } else {
            print("Unknown error type occurred.")
        }
    }
}
