//
//  ProfileViewController.swift
//  DocUp-ios
//
//  Created by админ on 09.05.2021.
//  Copyright © 2021 админ. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, URLSessionDelegate {

    var token:String!
    
    override func viewDidLoad() {
        print("📘","PROCESSING: ProfileViewController initialization...")
        super.viewDidLoad()

        self.navigationItem.hidesBackButton=true
        print("📗","SUCCESS: ProfileViewController initialized")
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    
    
}
