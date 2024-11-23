//
//  NewsFeedView.swift
//  One-ui
//
//  Created by Trieveon Cooper on 11/20/24.
//

import SwiftUI

struct NewsFeedView: View {
    @StateObject var networkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            List(networkManager.articles) { article in
                VStack(alignment: .leading) {
                    Text(article.title)
                        .font(.headline)
                    if let description = article.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Text("Published: \(article.publishedAt)")
                        .font(.footnote)
                        .foregroundColor(.blue)
                    Divider()
                }
                .onTapGesture {
                    if let url = URL(string: article.url) {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .navigationTitle("Global Issues News")
            .onAppear {
                networkManager.fetchNews()
            }
        }
    }
}

#Preview {
    NewsFeedView()
}
