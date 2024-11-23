import SwiftUI

// Main View to wrap all screens and the Bottom Navigation Bar
struct MainView: View {
    @State private var currentScreen: String = "charity" // Track which screen is active
    
    var body: some View {
        NavigationView {
            VStack {
                // Main content area where different screens will be shown
                Spacer() // Push content upwards

                // Determine which screen to show based on currentScreen value
                if currentScreen == "charity" {
                    CharitySelectionView()
                } else if currentScreen == "screen2" {
                    Screen2View()
                } else if currentScreen == "screen3" {
                    Screen3View()
                }
                
                // Always-visible Bottom Navigation Bar
                BottomNavigationBar(currentScreen: $currentScreen)
            }
            .background(Color(white: 0.95)) // Background color for screens
            .navigationBarTitle("") // Remove navigation bar title
            .navigationBarHidden(true) // Hide the default navigation bar
        }
    }
}

// Screen 2 for testing navigation
struct Screen2View: View {
    var body: some View {
        VStack {
            Text("This is Screen 2")
                .font(.largeTitle)
                .padding()
        }
    }
}

// Screen 3 for testing navigation
struct Screen3View: View {
    var body: some View {
        VStack {
            Text("This is Screen 3")
                .font(.largeTitle)
                .padding()
        }
    }
}

// Bottom Navigation Bar (Global Navigation Bar)
struct BottomNavigationBar: View {
    @Binding var currentScreen: String
    
    // Set the icon color to black
    let iconColor = Color.black
    
    var body: some View {
        HStack {
            Button(action: { currentScreen = "charity" }) {
                Image(systemName: "house.fill")
                    .font(.system(size: 24))
                    .foregroundColor(iconColor) // Set icon color to black
            }
            Spacer()
            Button(action: { currentScreen = "screen2" }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24))
                    .foregroundColor(iconColor) // Set icon color to black
            }
            Spacer()
            Button(action: { currentScreen = "screen3" }) {
                Image(systemName: "person.fill")
                    .font(.system(size: 24))
                    .foregroundColor(iconColor) // Set icon color to black
            }
            Spacer()
            Button(action: { currentScreen = "screen4" }) {
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(iconColor) // Set icon color to black
            }
            Spacer()
            Button(action: { currentScreen = "screen5" }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(iconColor) // Set icon color to black
            }
        }
        .padding()
        .background(Color(white: 0.9)) // Set bottom nav bar color to the same as search box (light gray)
        .cornerRadius(30)
        .shadow(radius: 10)
        .padding([.leading, .trailing], 20)
        .padding(.bottom, 10) // Ensure bottom spacing
    }
}

// Preview
#Preview {
    MainView()
}
