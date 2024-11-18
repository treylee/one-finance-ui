import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Ensure Firebase is configured at the very start
        FirebaseApp.configure()
        print("Firebase has been configured")
        return true
    }
}

@main
struct One_uiApp: App {
    // Attach the custom AppDelegate to the app
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            PaymentView()   // Your main view
        }
    }
}
