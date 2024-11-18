import FirebaseFirestore
import Swift
import Combine

class FirestoreManager: ObservableObject {
    @Published var amount: Int = 0
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // Document ID for the specific document we want to listen to
    private var documentId: String
    
    init(documentId: String) {
        self.documentId = documentId
        self.startListening()
    }
    
    // Start listening to changes in Firestore
    func startListening() {
        // Assuming you're listening to a specific document in the "payments" collection
        listener = db.collection("payments").document(documentId).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self else { return }
            
            if let document = documentSnapshot, document.exists {
                // Update the amount from Firestore
                if let amount = document.get("amount") as? Int {
                    self.amount = amount
                }
            } else {
                print("Document does not exist or there is an error: \(String(describing: error))")
            }
        }
    }
    
    // Stop listening when no longer needed
    func stopListening() {
        listener?.remove()
    }
}
