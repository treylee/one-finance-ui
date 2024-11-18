import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var balance: Int = 0
    @State private var displayedBalance: Int = 0
    @State private var isAnimating: Bool = false
    let db = Firestore.firestore()

    var body: some View {
        VStack {
            Text("Current Amount:")
                .font(.headline)
                .padding()

            // Scrolling number animation
            Text("\(displayedBalance)")
                .font(.largeTitle)
                .bold()
                .padding()
                .foregroundColor(.blue)
                .onChange(of: balance) { newValue in
                    // Start the scrolling animation when the balance changes
                    startScrollingAnimation(from: displayedBalance, to: newValue)
                }

            Button(action: {
                // Example to update the Firestore amount value
                updateAmountInFirestore(newAmount: balance + 100)
            }) {
                Text("Increase balance")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Listen for Firestore updates in real-time
            .onAppear {
                startListeningForAmountUpdates()
            }
        }
    }

    // Function to start the number scrolling animation
    func startScrollingAnimation(from startValue: Int, to endValue: Int) {
        // If an animation is already in progress, don't start a new one
        guard !isAnimating else { return }

        isAnimating = true

        // Duration and interval between updates
        let duration: Double = 1.5
        let totalSteps = abs(endValue - startValue)
        let stepInterval = duration / Double(totalSteps)

        // Start a timer to update the displayed balance over time
        var currentValue = startValue
        Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { timer in
            if currentValue < endValue {
                currentValue += 1
            } else if currentValue > endValue {
                currentValue -= 1
            } else {
                timer.invalidate()
                isAnimating = false
            }
            // Update the displayed balance on the UI
            self.displayedBalance = currentValue
        }
    }

    // Function to start listening for Firestore updates in real-time
    func startListeningForAmountUpdates() {
        let docRef = db.collection("charity").document("mother") // Replace with the correct document ID

        // Use a real-time listener that will automatically update when the document changes
        docRef.addSnapshotListener { document, error in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                // If the document exists, read the data
                if let balance = document.get("balance") as? Int {
                    print("Document updated with new balance: \(balance)") // Log the updated balance
                    self.balance = balance  // Update the local state with the Firestore amount
                } else {
                    print("Balance field does not exist in the document.")
                }
            } else {
                print("Document does not exist.")
            }

            // Log that the listener is active and polling
            print("Firestore listener is polling... Document update check complete.")
        }
    }

    // Function to update Firestore with a new amount
    func updateAmountInFirestore(newAmount: Int) {
        let docRef = db.collection("charity").document("mother") // Replace with the correct document ID

        docRef.updateData([
            "balance": newAmount
        ]) { error in
            if let error = error {
                print("Error updating Firestore: \(error)")
            } else {
                print("Successfully updated Firestore with new amount: \(newAmount)")
            }
        }
    }
}
