import SwiftUI
import PassKit
import Stripe

struct StripeView: View {
    @State private var paymentStatus: String?
    @State private var paymentAmount: Double = 10.99
    
    var body: some View {
        VStack {
            Text("Apple Pay with Stripe")
                .font(.title)
                .padding()
            
            Text("Amount: $\(paymentAmount, specifier: "%.2f")")
                .font(.headline)
                .padding()
            
            ApplePayButton()
                .frame(width: 200, height: 50)
                .onTapGesture {
                    startApplePay()
                }
            
            if let status = paymentStatus {
                Text(status)
                    .foregroundColor(status.contains("Success") ? .green : .red)
                    .padding()
            }
        }
    }
    
    func startApplePay() {
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: "merchant.com.yourcompany.yourapp", country: "US", currency: "USD")
        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "Your Product", amount: NSDecimalNumber(value: paymentAmount))]
        
        if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) {
            applePayContext.presentApplePay()
        } else {
            paymentStatus = "Apple Pay not available"
        }
    }
}

extension ContentView: STPApplePayContextDelegate {
    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: STPPaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        // Call your server to create a PaymentIntent
        createPaymentIntent { clientSecret in
            completion(clientSecret, nil)
        }
    }
    
    func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPPaymentStatus, error: Error?) {
        DispatchQueue.main.async {
            switch status {
            case .success:
                self.paymentStatus = "Payment Successful!"
            case .error:
                self.paymentStatus = "Payment Failed: \(error?.localizedDescription ?? "Unknown error")"
            case .userCancellation:
                self.paymentStatus = "Payment Canceled"
            @unknown default:
                self.paymentStatus = "Unknown Payment Status"
            }
        }
    }
    
    func createPaymentIntent(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://your-server.com/create-payment-intent") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["amount": paymentAmount, "currency": "usd"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let clientSecret = json["clientSecret"] as? String {
                completion(clientSecret)
            } else {
                print("Invalid JSON response")
                completion(nil)
            }
        }.resume()
    }
}

#Preview {
    StripeView()
}
