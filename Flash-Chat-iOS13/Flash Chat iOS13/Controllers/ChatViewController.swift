//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        print("Log Out Pressed")
        do {
            try Auth.auth().signOut()
            print("Signing out")
            self.navigationController?.popToRootViewController(animated: true)
            print("navigation done")
            //navigationController?.present(WelcomeViewController(), animated: false, completion: nil)
        } catch let signOutError {
            print(signOutError.localizedDescription)
        }
    }
    
}
