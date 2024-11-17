//
//  PlaidConfiguration.swift
//  One
//
//  Created by Trieveon Cooper on 11/11/24.
//

//mport PlaidLink

class PlaidConfiguration {
    static let shared = PlaidConfiguration()
    private init() {}
    
    let publicKey = "your_plaid_public_key"
    let env = LinkToken.Environment.sandbox  // Use `.sandbox` or `.production`
}

