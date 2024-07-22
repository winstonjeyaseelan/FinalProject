//
//  ViewController.swift
//  FinalProject
//
//  Created by apple on 26/03/2024.
//

//w_jeyaseelan200960@fanshaweonline.ca
import UIKit
import FirebaseAuth
import SwiftJWT


class ViewController: UIViewController {
    
    //iboutlet initialization
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Loginbutton: UIButton!
    @IBOutlet weak var Labels: UILabel!
    @IBOutlet weak var label: UIView!
    
    //globals
    var tasks: [String: [String: Any]] = [:]
    var globalTokenWithSignature: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //disable login button
        Loginbutton.isEnabled = false
        
        Email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        Password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let email = Email.text, let password = Password.text else { return }
        Loginbutton.isEnabled = !email.isEmpty && !password.isEmpty
    }
    
    //on login click using fire sdk
    //using the auth obj and signIn method to login using the credentials
    @IBAction func onClickLoginbutton(_ sender: UIButton) {
        guard let email = Email.text, let password = Password.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let authResult = authResult, error == nil else {
                print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    // updating the label with error message
                    self?.Labels.text = "Invalid Credentials"
                }
                return
            }
            print("Logged in successfully!")
            
            // get the token details here
            authResult.user.getIDToken(completion: { (token, error) in
                guard let token = token, error == nil else {
                    print("error getting ID token: \(error!.localizedDescription)")
                    DispatchQueue.main.async {
                        // Update label with error message
                        self?.Labels.text = "invalid"
                    }
                    return
                }
                let storyboard = UIStoryboard(name: "TableView", bundle: nil)
                if let listTableViewController = storyboard.instantiateViewController(withIdentifier: "tableView") as? TableViewController {
                    listTableViewController.authToken = token
                    listTableViewController.modalPresentationStyle = .fullScreen
                    if let viewController = self as? ViewController {
                        viewController.present(listTableViewController, animated: true, completion: nil)
                    } else {
                        print("cant present view controller")
                    }
                }
                print("Token: \(token)")
                
            })
        }
    }
    
    
}
