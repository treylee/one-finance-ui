//
//  User.swift
//  One
//
//  Created by Trieveon Cooper on 11/10/24.
//

import FirebaseFirestore

struct User {
    var username: String
    var email: String
    var password: String

    // Regular initializer to create a User from data
    init(username: String, email: String, password: String) {
        self.username = username
        self.email = email
        self.password = password
    }

    // Convert the User object to a dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "username": username,
            "email": email,
            "password": password
        ]
    }

    // Convenience initializer to create a User from a Firestore document
    init?(from document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard let username = data["username"] as? String,
              let email = data["email"] as? String,
              let password = data["password"] as? String else { return nil }
        self.username = username
        self.email = email
        self.password = password
    }
}
