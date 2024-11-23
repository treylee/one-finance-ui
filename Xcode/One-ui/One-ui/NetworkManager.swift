import Foundation

// Define your structure to match the API response
struct NewsResponse: Codable {
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

class NetworkManager: ObservableObject {
    @Published var articles: [Article] = []
    
    func fetchNews() {
        let urlString = "https://newsapi.org/v2/everything?q=world+issues&apiKey=659b7fdecf074ea190a904592185fbb3"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.articles = decodedResponse.articles
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
}
