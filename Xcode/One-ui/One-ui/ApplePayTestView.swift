import SwiftUI
import PassKit
import Stripe
import StripePaymentSheet

struct ApplePayTestView: View {
    @State private var isApplePayAvailable = false
    @State private var canMakePayments = false
    @State private var paymentResultMessage: String?
    @State private var isProcessingPayment = false
    @State private var paymentSheet: PaymentSheet?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Apple Pay Test & Payment")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let paymentResultMessage = paymentResultMessage {
                Text(paymentResultMessage)
                    .foregroundColor(paymentResultMessage.contains("failed") ? .red : .green)
                    .font(.headline)
            }
            
            if isProcessingPayment {
                ProgressView("Processing...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
            if isApplePayAvailable && canMakePayments {
                Button("Pay with Apple Pay") {
                    startPaymentProcess()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Text("❌ Apple Pay is not available or not set up correctly.")
                    .foregroundColor(.red)
            }
            
            Button("Check Apple Pay") {
                checkApplePay()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            checkApplePay()
        }
    }

    // Check if Apple Pay is available on the device and if the user can make payments
    func checkApplePay() {
        if PKPaymentAuthorizationViewController.canMakePayments() {
            isApplePayAvailable = true
            checkPaymentMethods()
        } else {
            isApplePayAvailable = false
            canMakePayments = false
            paymentResultMessage = "❌ Apple Pay is not available on this device."
        }
    }

    // Check if the user has payment methods available (Visa, MasterCard, AMEX)
    func checkPaymentMethods() {
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.visa, .masterCard, .amex]) {
            canMakePayments = true
        } else {
            canMakePayments = false
            paymentResultMessage = "❌ No valid payment methods are set up for Apple Pay."
        }
    }

    // Start the payment process by creating a Payment Intent and presenting the PaymentSheet
    func startPaymentProcess() {
        // Step 1: Request a Payment Intent from the backend
        fetchPaymentIntentFromBackend { clientSecret in
            // Step 2: Set up the PaymentSheet with the client secret
            var configuration = PaymentSheet.Configuration()
            configuration.applePay = .init(merchantId: "merchant.treylee.one-ui", merchantCountryCode: "US")

            let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
            self.paymentSheet = paymentSheet
            
            // Step 3: Show the PaymentSheet for the user to authenticate
            DispatchQueue.main.async {
                self.isProcessingPayment = true
                // Use UIViewControllerRepresentable to present the PaymentSheet
                PaymentSheetPresenter(paymentSheet: paymentSheet) { paymentResult in
                    self.isProcessingPayment = false
                    handlePaymentResult(paymentResult)
                }.present()
            }
        }
    }

    // Fetch the Payment Intent from your backend
    func fetchPaymentIntentFromBackend(completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://c9b5-173-94-62-99.ngrok-free.app/create-payment-intent") else {
            DispatchQueue.main.async {
                self.paymentResultMessage = "❌ Invalid URL for backend API."
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["amount": 1000, "currency": "usd"] // Amount in cents
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.paymentResultMessage = "❌ Error fetching payment intent: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.paymentResultMessage = "❌ No data received from backend."
                }
                return
            }
            
            // Debugging: Log the raw response data
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Backend Response: \(rawResponse)")
            }

            // Try to parse the JSON response
            if let responseJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let clientSecret = responseJson["clientSecret"] as? String {
                DispatchQueue.main.async {
                    completion(clientSecret)
                }
            } else {
                DispatchQueue.main.async {
                    self.paymentResultMessage = "❌ Failed to parse backend response."
                }
            }
        }

        task.resume()
    }

    // Handle the result of the payment
    func handlePaymentResult(_ paymentResult: PaymentSheetResult) {
        switch paymentResult {
        case .completed:
            self.paymentResultMessage = "✅ Payment completed successfully!"
        case .canceled:
            self.paymentResultMessage = "🚫 Payment was canceled by the user."
        case .failed(let error):
            self.paymentResultMessage = "❌ Payment failed with error: \(error.localizedDescription)"
        }
    }
}

// UIViewControllerRepresentable to present the PaymentSheet in SwiftUI
struct PaymentSheetPresenter: UIViewControllerRepresentable {
    let paymentSheet: PaymentSheet
    let completion: (PaymentSheetResult) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController() // Dummy view controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func present() {
        // Present the PaymentSheet
        paymentSheet.present(from: UIApplication.shared.windows.first!.rootViewController!) { paymentResult in
            self.completion(paymentResult)
        }
    }
}

struct ApplePayTestView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayTestView()
    }
}
