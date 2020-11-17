//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseCoreDiagnostics

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = [
        Message(sender: "abc123@gmail.com", body: "Hey"),
        Message(sender: "def456@gmail.com", body: "Hello"),
        Message(sender: "abc123@gmail.com", body: "Whazzzzzuuuuppppp")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        print("Load Messages called")
        self.loadMessages()
        print("Load Messages done with execution")
    }
    
    func loadMessages() {
        print("Inside Load Messages")
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            if let e = error {
                print("Issue with retrieving data from the Database: \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        print(doc.data())
                        let messageData = doc.data()
                        if let messageSender = messageData[K.FStore.senderField] as? String, let messageBody = messageData[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            DispatchQueue.main.async() {
                                self.tableView.reloadData()
                                let indexpath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexpath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection("users").addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { error in
                if let err = error {
                    print("Problem adding document to the Firestore Database: \(err)")
                } else {
                    print("Data saved successfully")
                    self.tableView.reloadData()
                    
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
           
        }
       
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        print("Log Out Pressed")
        do {
            try Auth.auth().signOut()
            print("Signing out")
            //self.navigationController?.popToRootViewController(animated: true)
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)

            print("navigation done")
            //navigationController?.present(WelcomeViewController(), animated: false, completion: nil)
        } catch let signOutError {
            print(signOutError.localizedDescription)
        }
    }
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.msgLabel.text = message.body
        
        //Message from current user
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.msgLabel.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            // Message from another user
                cell.leftImageView.isHidden = false
                cell.rightImageView.isHidden = true
                cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
                cell.msgLabel.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        return cell
    }
        
}


extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row is \(indexPath.row)")
    }
}
