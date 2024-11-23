import SwiftUI
import StripeCore
import StripePaymentSheet
import PassKit

struct PaymentView: View {
    @State private var isProcessingPayment = false
    @State private var paymentSheet: PaymentSheet?
    @State private var paymentSucceeded = false // State to track successful payment
    @State private var showErrorAlert = false // State to show error alert
    @State private var errorMessage = "" // State to store error message
    @State private var isPaymentInProgress = false // State to track payment in progress

    var body: some View {
        VStack {
            if isProcessingPayment {
                ProgressView("Processing...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button("Pay with Apple Pay") {
                    isPaymentInProgress = true
                        startApplePay()
                }
                .padding()
                .disabled(isPaymentInProgress)  // Disable button when payment is in progress
            }
            
            // Show content view if payment succeeded
            if paymentSucceeded {
                ContentView() // The content view after successful payment
            }
        }
        .onAppear {
            // Initialize Stripe publishable key only when the view appears
            StripeAPI.defaultPublishableKey = "pk_test_51QLo6WBsR5frtF6syrD7xI8NcdzPmqSqLsoPQjQPrgFHIPN1jD2m5EyPwVYgVNvwRHka5i9HYXfeagUv3gIicxFV00WDdP65OQ"
        }
        // Show error alert if there's an error
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Payment Unavailable"),
                  message: Text(errorMessage),
                  dismissButton: .default(Text("OK")))
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
                // Check if the current root view controller is presenting another view controller
                if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
                   rootViewController.presentedViewController == nil {
                    print("🔲 Presenting PaymentSheet...")
                    self.isPaymentInProgress = true // Disable the button and show loading indicator
                    paymentSheet.present(from: rootViewController) { paymentResult in
                        // Only set `isPaymentInProgress = false` after the completion handler
                        self.isPaymentInProgress = false // Enable the button after payment result
                        self.isProcessingPayment = false // Hide loading indicator
                        
                        switch paymentResult {
                        case .completed:
                            print("✅ Payment completed successfully!")
                            // After successful payment, update the state to show content view
                            self.paymentSucceeded = true
                        case .canceled:
                            print("🚫 Payment was canceled by the user.")
                        case .failed(let error):
                            print("❌ Payment failed with error: \(error.localizedDescription)")
                            logPaymentError(error)
                        }
                    }
                } else {
                    print("❌ PaymentSheet cannot be presented. Another view controller is already being presented.")
                }
            }
        }
    }
    
    func fetchPaymentIntentFromBackend(completion: @escaping (String, Int) -> Void) {
        guard let url = URL(string: "https://d19a-2600-1700-25d8-4130-b501-290b-18f2-a877.ngrok-free.app/create-payment-intent") else {
            print("❌ Invalid URL for backend API.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Define the amount in cents
        let amount = 1000 // Amount in cents
        let body: [String: Any] = ["amount": amount, "currency": "usd","charity":"hardcore"]
        print("🔄 Sending request to backend with data: \(body)")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching payment intent: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Payment Unavailable. Please try again later."
                    self.showErrorAlert = true // Show the error alert
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data received from backend.")
                DispatchQueue.main.async {
                    self.errorMessage = "Payment Unavailable. Please try again later."
                    self.showErrorAlert = true // Show the error alert
                }
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
                    DispatchQueue.main.async {
                        self.errorMessage = "Payment Unavailable. Please try again later."
                        self.showErrorAlert = true // Show the error alert
                    }
                }
            } else {
                print("❌ Error parsing backend response.")
                DispatchQueue.main.async {
                    self.errorMessage = "Payment Unavailable. Please try again later."
                    self.showErrorAlert = true // Show the error alert
                }
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

