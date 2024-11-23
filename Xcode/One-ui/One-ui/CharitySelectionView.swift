    import SwiftUI

    // MARK: - Main Charity Selection View
    struct CharitySelectionView: View {
        @State private var selectedCharity: Charity? = nil
        @State private var searchQuery = ""
        @State private var currentScreen: String = "charity" // Track which screen is active
        @State private var isSidePanelVisible = false // Track the visibility of the side panel

        // Sample data for Charities with default image names
        let charities = [
            Charity(name: "Mental Help", location: "New York", price: "$120/night", image: "https://www.example.com/house1.jpg"),
            Charity(name: "Cancer Research", location: "Miami", price: "$250/night", image: "https://www.example.com/house2.jpg"),
            Charity(name: "International Aid", location: "Aspen", price: "$180/night", image: "https://www.example.com/house3.jpg")
        ]
        
        var body: some View {
            NavigationView {
                ZStack {
                    VStack {
                        if currentScreen == "charity" {
                            // Charity Selection Screen
                            CharityListView(charities: charities, selectedCharity: $selectedCharity, searchQuery: $searchQuery, isSidePanelVisible: $isSidePanelVisible)
                        } else if currentScreen == "screen2" {
                            // Screen 2
                            Text("This is Screen 2")
                                .font(.largeTitle)
                                .padding()
                        } else if currentScreen == "screen3" {
                            // Screen 3
                            Text("This is Screen 3")
                                .font(.largeTitle)
                                .padding()
                        }
                    }
                    .background(Color(white: 0.95)) // Light gray background
                    .navigationBarTitle("") // Remove the navigation bar title
                    .navigationBarHidden(true) // Hide the default navigation bar
                    .disabled(isSidePanelVisible || selectedCharity != nil) // Disable background interaction when side panel or detail view is visible
                    .overlay(
                        Group {
                            if let selectedCharity = selectedCharity {
                                CharityDetailView(charity: selectedCharity, onClose: {
                                    withAnimation { self.selectedCharity = nil }
                                })
                                .transition(.move(edge: .bottom))
                                .zIndex(1) // Ensure it's above the background
                            }
                        }
                    )

                    // Dimming background overlay when the side panel is visible
                    if isSidePanelVisible {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                            .zIndex(1) // Place it behind the side panel, but in front of the main content
                            .onTapGesture {
                                withAnimation {
                                    isSidePanelVisible = false // Close the side panel when the dimmed background is tapped
                                }
                            }
                    }
                    
                    // Side Panel View (always interactive when visible)
                    if isSidePanelVisible {
                        SidePanelView(isSidePanelVisible: $isSidePanelVisible)
                            .transition(.move(edge: .trailing)) // Side panel animation from the right
                            .zIndex(2) // Ensure it's above the background and the dimmed overlay
                    }
                }
            }
        }
    }

    // MARK: - Charity List View
    struct CharityListView: View {
        let charities: [Charity]
        @Binding var selectedCharity: Charity?
        @Binding var searchQuery: String // Bind to search query
        @Binding var isSidePanelVisible: Bool // Bind to side panel visibility

        var body: some View {
            VStack {
                // Search Bar with side panel icon on the right
                SearchBar(searchQuery: $searchQuery, isSidePanelVisible: $isSidePanelVisible)
                
                // Charities list view (below search bar)
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(charities.filter { charity in
                            // Filter charities based on search query
                            searchQuery.isEmpty || charity.name.localizedCaseInsensitiveContains(searchQuery)
                        }) { charity in
                            CharityCardView(charity: charity)
                                .onTapGesture {
                                    withAnimation {
                                        selectedCharity = charity
                                    }
                                }
                        }
                    }
                    .padding()
                    .frame(maxHeight: .infinity) // Make sure the ScrollView stretches to full height
                }
            }
            .frame(maxHeight: .infinity) // Ensure the entire content stretches to the bottom
        }
    }


    // MARK: - Search Bar View
    struct SearchBar: View {
        @Binding var searchQuery: String
        @Binding var isSidePanelVisible: Bool

        var body: some View {
            VStack {
                // Logo at the top of the SearchBar section
                HStack {
                    Spacer()
                    Image(systemName: "fish") // Replace with your logo or custom image
                        .font(.system(size: 24)) // Smaller size for the top icon
                        .foregroundColor(.black) // Black color for the icon
                    Spacer()
                }
                .padding(.top)

                // Search Bar with side panel icon on the right
                HStack {
                    TextField("Search for Charities", text: $searchQuery)
                        .padding(.horizontal, 16)
                        .frame(height: 50) // Larger search bar height
                        .background(Color(white: 0.9)) // Light gray search box
                        .cornerRadius(30)
                        .foregroundColor(.gray)
                        .disableAutocorrection(true)
                        .overlay(
                            HStack {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black) // Black color for the search icon
                                    .padding(.trailing, 16)
                            }
                        )
                    
                    // Side panel button (filter icon)
                    Button(action: {
                        withAnimation {
                            isSidePanelVisible.toggle() // Toggle side panel visibility
                        }
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill") // Filter icon
                            .font(.title)
                            .foregroundColor(.black) // Black color for the filter icon
                            .padding(.trailing, 16)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
    }

    // MARK: - Side Panel View (Popup Modal)
    struct SidePanelView: View {
        @Binding var isSidePanelVisible: Bool

        let icons = ["house.fill", "heart.fill", "lightbulb.fill", "flame.fill", "star.fill"] // Sample icons

        var body: some View {
            VStack {
                // Title at the top
                Text("Charity Types")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 30)
                    .padding(.bottom, 20)

                // Spacer to push content down, making room for the button in the center
                Spacer()
                
                // Close button in the center
                Button(action: {
                    withAnimation {
                        isSidePanelVisible = false // Close the side panel when the button is tapped
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding(20)
                }
                
                // Spacer to push content up, ensuring the button stays centered
                Spacer()

                // Scrollable list of icons and labels
                ScrollView {
                    VStack(spacing: 25) {
                        ForEach(icons, id: \.self) { icon in
                            HStack {
                                Image(systemName: icon)
                                    .font(.system(size: 24)) // Smaller icon size
                                    .foregroundColor(.black) // Black color for the icons
                                
                                Text(icon)
                                    .font(.subheadline) // Smaller text size
                                    .foregroundColor(.black) // Black color for text
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20) // Add space at the top of the list
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.21, green: 0.21, blue: 0.21)) // Solid gray-600 background
            .cornerRadius(20)
            .padding(40)
            .transition(.move(edge: .trailing)) // Animation from the right
        }
    }

    // MARK: - Charity Card View
    struct CharityCardView: View {
        let charity: Charity

        var body: some View {
            ZStack {
                // Use AsyncImage for optimized image loading
                AsyncImage(url: URL(string: charity.image)) { phase in
                    switch phase {
                    case .empty: // Placeholder when image is loading
                        Color.gray
                            .frame(height: 200)
                            .cornerRadius(15)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    case .failure: // Fallback to default image if loading fails
                        Image("house1") // Replace "house3" with the name of your image in Assets
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    @unknown default:
                        EmptyView()
                    }
                }
                VStack {
                    Spacer()
                    Text(charity.name)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    Text(charity.location)
                        .foregroundColor(.white)
                        .padding(.bottom)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
            .frame(height: 200)
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }

    // MARK: - Charity Detail View
    struct CharityDetailView: View {
        let charity: Charity
        var onClose: () -> Void

        var body: some View {
            VStack {
                // Close button in the top-right corner
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            onClose() // Close the modal
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white) // White close button to stand out
                            .padding(.top, 20)
                            .padding(.trailing, 20)
                    }
                }
                VStack {
                    // Charity Image (using AsyncImage with a fallback to default image)
                    AsyncImage(url: URL(string: charity.image)) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .padding(.top, 20)
                    } placeholder: {
                        // Fallback to a default image if AsyncImage fails
                        Image("house1") // Replace "house1" with your image name in Assets
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .padding(.top, 20)
                    }
                    
                    Text(charity.name)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top)
                    Text(charity.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    Text(charity.price)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("This is a beautiful \(charity.name) located in \(charity.location). Enjoy a peaceful and relaxing stay with all the amenities you need.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.bottom, 30)
                        }
                        .padding()
                    }
                    Spacer()
                }
                .background(Color(red: 0.294, green: 0.337, blue: 0.384)) // Dark gray similar to gray-600
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding(.horizontal)
                .padding(.top, 20)
                .frame(maxWidth: .infinity)
            }
            .background(Color(red: 0.294, green: 0.337, blue: 0.384).opacity(0.8).edgesIgnoringSafeArea(.all)) // Dark gray overlay with some transparency
        }
    }

    // MARK: - Charity Model
    struct Charity: Identifiable {
        let id = UUID()
        let name: String
        let location: String
        let price: String
        let image: String
    }

    // MARK: - Preview
    struct CharitySelectionView_Previews: PreviewProvider {
        static var previews: some View {
            CharitySelectionView()
        }
    }
