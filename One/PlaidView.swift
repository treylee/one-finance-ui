////
////  PlaidView.swift
////  One
////
////  Created by Trieveon Cooper on 11/11/24.
////
//
//import SwiftUI
//
//import SwiftUI
////import PlaidLink
//
//struct PlaidView: View {
//    @State private var linkToken: String?
//    @State private var accessToken: String?
//    @State private var errorMessage: String?
//    
//    var body: some View {
//        VStack {
//            if let accessToken = accessToken {
//                Text("Account linked! Access token: \(accessToken)")
//            } else {
//                Button("Link Bank Account with Plaid") {
//                    fetchLinkToken()
//                }
//                .padding()
//                
//                if let errorMessage = errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                }
//            }
//        }
//        .onAppear {
//            fetchLinkToken()
//        }
//    }
//    
//    func fetchLinkToken() {
//        // Call your backend to fetch the Plaid Link token
//        let url = URL(string: "https://your-backend.com/create_link_token")!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        // Add any required headers, body, etc.
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                DispatchQueue.main.async {
//                    self.errorMessage = error?.localizedDescription ?? "Unknown error"
//                }
//                return
//            }
//            
//            do {
//                let response = try JSONDecoder().decode(PlaidLinkResponse.self, from: data)
//                DispatchQueue.main.async {
//                    self.linkToken = response.linkToken
//                    self.openPlaidLink()
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//        }.resume()
//    }
//    
//    func openPlaidLink() {
//        guard let linkToken = linkToken else { return }
//        
//        // Initialize Plaid Link using the token
//        PlaidLink.setup(linkToken: linkToken) { (success, metadata) in
//            if success {
//                self.accessToken = metadata?.accessToken
//                print("Linking successful. Access Token: \(self.accessToken ?? "")")
//            } else {
//                self.errorMessage = metadata?.error?.localizedDescription
//                print("Linking failed: \(self.errorMessage ?? "Unknown error")")
//            }
//        }
//    }
//}
//
//struct PlaidLinkResponse: Decodable {
//    let linkToken: String
//}
//
//
//#Preview {
//    PlaidView()
//}
//
