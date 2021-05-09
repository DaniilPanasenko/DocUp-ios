//
//  ViewController.swift
//  DocUp-ios
//
//  Created by админ on 5/5/21.
//  Copyright © 2021 админ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        print("📘","PROCESSING: Start working...")
        print("📘","PROCESSING: MainViewController initialization...")
        super.viewDidLoad()
        print("📗","SUCCESS: MainViewController initialized")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sleep(2)
        let LoginPage = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        navigationController?.pushViewController(LoginPage!, animated: true)
    }


}

