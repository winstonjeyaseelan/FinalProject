//
//  TableViewController.swift
//  FinalProject
//
//  Created by apple on 26/03/2024.
//

import UIKit
import FirebaseAuth
import SwiftJWT

class TableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    //initialize iboutlets here.
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Add: UIBarButtonItem!
    
    //required variables. globals
    var tasks: [Task] = []
    var authToken: String?
    var jsontrack: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //reuired table view intializations
        tableView.dataSource = self
        self.tableView.allowsSelection = true
        self.tableView.delegate = self
        print("Toooooooooooookennnnnnnn",authToken)
        Add.target = self
        loadTasks()
        callnetworklink()
        
    }
    
    //add button to naviagate to the detailed page to add the details
    @IBAction func Add(_ sender: Any) {
        let storyboard = UIStoryboard(name: "DetailScreen", bundle: nil)
        if let detailScreenViewController = storyboard.instantiateViewController(withIdentifier: "dscreen") as? UIViewController {
            detailScreenViewController.modalPresentationStyle = .fullScreen
            self.present(detailScreenViewController, animated: true, completion: nil)
        }
        print("here......")
    }
    
    //network call to get the network data from firebase using the
    //rest api call as mentioned in the project network requirement
    func callnetworklink(){
        
        guard let token = authToken else {
            print("Error: Authentication token is nil")
            return
        }
        //claims file to verify the jwt token signature as in the firebase documentation
        //given to us
        struct MyPay: Claims {
            let iss: String
            let aud: String
            let auth_time: Date
            let user_id: String
            let sub: String
            let iat: Date
            let exp: Date
            let email: String
            let email_verified: Bool
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                iss = try container.decode(String.self, forKey: .iss)
                aud = try container.decode(String.self, forKey: .aud)
                auth_time = try container.decode(Date.self, forKey: .auth_time)
                user_id = try container.decode(String.self, forKey: .user_id)
                sub = try container.decode(String.self, forKey: .sub)
                iat = try container.decode(Date.self, forKey: .iat)
                exp = try container.decode(Date.self, forKey: .exp)
                email = try container.decode(String.self, forKey: .email)
                email_verified = try container.decode(Bool.self, forKey: .email_verified)
            }
            
            enum CodingKeys: String, CodingKey {
                case iss, aud, auth_time, user_id, sub, iat, exp, email, email_verified
            }
        }
        
        //public key found in the firebase documentation
        let mypublicKey = """
        -----BEGIN CERTIFICATE-----
        MIIDHDCCAgSgAwIBAgIIZ2dzT9WemtwwDQYJKoZIhvcNAQEFBQAwMTEvMC0GA1UE
        Awwmc2VjdXJldG9rZW4uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wHhcNMjQw
        NDA2MDczMjE4WhcNMjQwNDIyMTk0NzE4WjAxMS8wLQYDVQQDDCZzZWN1cmV0b2tl
        bi5zeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbTCCASIwDQYJKoZIhvcNAQEBBQAD
        ggEPADCCAQoCggEBAKQ3w/uKFXqIB1CBJVI9olD7JTWaQ6+O5M215qkQR8FzFeGv
        BBJQtyEYCinaxTpMJVmp42LTR71Q5VB3IYdHUhpYhgRmpXvzJfGgdn19p/xL1tyx
        4sYVEqNjepvzlwsql+VQKTi6d89wL5UzPaun/FR3bdqdj68I4Q8NsF7/pWJJ514I
        vvpesA+8Pwb68NmbLOqghaMlN6AmY/alOBnlKP84si0Asa1Y5e6B8Mpqz+CimX4u
        TXEesUqBM58S0pwwlD/97fqK1y73ZJyspos0Jg8UYkZDXqpOFbcSi4l8a7+ALbrc
        I2z2vGJjYDn1bR7CyXOIN7cquAlXr+hiYUwavUkCAwEAAaM4MDYwDAYDVR0TAQH/
        BAIwADAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwIwDQYJ
        KoZIhvcNAQEFBQADggEBADiD+YbC4ogHyVOuptAdve9VxwPvWtiU2VISXj9FrMtU
        SoMBYE3m9G3g09tcEZYWyqMA7NLbkQxCnQ3eOoF9QQVb3ATipwItnd8gX6mqzC+o
        R8NVo7W6NB7pCklkK5HwPVVNinaUvfdT65OXtZ/XFgqIqgDzSDD6AGskNi4VMH+R
        y9HMSisc9Fd/6XBtxWSnERSxxdJYp9FAXMH7cVTCmZxDEn1nc7RnCzsJqlpLqQZW
        0Cn5pJDvpmWR238CkaSFn1+/VL2RasiBj0FnxVL8FUT/+C9LKX9KZ9S3PKnoKKNM
        TMp3qeRd75+IAkVDkWdJLPAVBbEULdcdzHj5joGniDI=
        -----END CERTIFICATE-----
        """
        
        //jwt using rs256
        let jwtVerifier = JWTVerifier.rs256(publicKey: mypublicKey.data(using: .utf8)!)
        
        // Verify the JWT token
        do {
            let verified = try JWT<MyPay>.verify(token, using: jwtVerifier)
            print("JWT signature verified successfully")
        } catch {
            print("JWT signature verification error: \(error)")
        }
        
        print("-----------------------------------------------")
        
        //rest api call here
        let databaseURL = "https://info-6125-5c725-default-rtdb.firebaseio.com/w24/project.json?auth=\(token)"
        
        guard let url = URL(string: databaseURL) else {
            print("Error: Invalid URL")
            return
        }
        //setting the url request header in this case its GET
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching tasks: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid HTTP response")
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            //converting json to string and sending it the table view controller
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Responsetable:")
                print(jsonString)
                self.jsontrack = jsonString
            } else {
                print("Error JSON data")
            }
        }
        
        task.resume()
        
    }
    //onlcik on the network button it shows the alert
    @IBAction func networkbtn(_ sender: Any) {
        print("......... network call here")
        if let jsonString = jsontrack {
            alertdisplaynetwork(jsonString: jsonString)
        } else {
            print("json string is nil")
        }
    }
    //alert function to show the alert here
    func alertdisplaynetwork(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8),
              let taskDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: [String: Any]] else {
            print("Error parsing JSON data")
            return
        }
        
        let alertController = UIAlertController(title: "All Tasks", message: nil, preferredStyle: .alert)
        
        //displaying the actual json and organizing it to print on the alert
        for (taskID, taskInfo) in taskDict {
            var taskString = "\(taskID):\n"
            for (key, value) in taskInfo {
                taskString += "\(key): \(value)\n"
            }
            
            let action = UIAlertAction(title: taskString, style: .default, handler: nil)
            alertController.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        
        var newcontroller = UIApplication.shared.windows.first?.rootViewController
        while let presentedViewController = newcontroller?.presentedViewController {
            newcontroller = presentedViewController
        }
        
        newcontroller?.present(alertController, animated: true, completion: nil)
    }
    //loading tasks here from the user defaults
    func loadTasks() {
        print("Loading tasks...")
        
        if let taskData = UserDefaults.standard.array(forKey: "tasks") as? [[String: Any]] {
            print("Retrieved task data:", taskData)
            tasks.removeAll()
            
            //looping through the user defaults list
            for taskDict in taskData {
                let title = taskDict["taskName"] as? String ?? ""
                let completedBy = taskDict["assignee"] as? String ?? ""
                let datestr = taskDict["taskDate"] as? String ?? ""
                let iconName = "square"
                var statusColor = UIColor.green
                
                if let taskStatus = taskDict["taskStatus"] as? String {
                    switch taskStatus {
                    case "Not Started":
                        statusColor = UIColor.white
                    case "In Progress":
                        statusColor = UIColor.yellow
                    case "Completed":
                        statusColor = UIColor.green
                    default:
                        break
                    }
                }
                
                let task = Task(title: title, completed_by: completedBy, date_completed: datestr, icon_name: iconName, status_color: statusColor)
                
                tasks.append(task)
            }
        }
        
        print("Tasks count:", tasks.count)
        
        tableView.reloadData()
        
        if tasks.isEmpty {
            let placeholderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            placeholderLabel.text = "No tasks available"
            placeholderLabel.textAlignment = .center
            tableView.backgroundView = placeholderLabel
        } else {
            tableView.backgroundView = nil
        }
    }
    
    
    //converting string to date here to to return
    func datetostring(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            return Date()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //table view cellforrowat function
    //here we are setting each cell with the respective infomations
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        
        let task = tasks[indexPath.row]
        
        print("WINSTOOOOOOOOOOOOOOOOOON",task.status_color);
        
        cell.Title?.text = task.title
        cell.Description?.text = "\(task.completed_by) on \(task.date_completed)"
        cell.Icon?.image = UIImage(systemName: task.icon_name)
        cell.Annotations?.image = UIImage(named: "circle")
        
        cell.backgroundColor = task.status_color
        
        return cell
    }
    
    //implemetation of the logout button
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            print("logout check")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true, completion: nil)
            }
        } catch let signOutError as NSError {
            print("there is an error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    //add button
    @IBAction func add(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DetailScreen", bundle: nil)
        if let detailScreenViewController = storyboard.instantiateViewController(withIdentifier: "dscreen") as? UIViewController {
            detailScreenViewController.modalPresentationStyle = .overFullScreen
            self.present(detailScreenViewController, animated: true, completion: nil)
        }
    }
    //table view didselect rows function
    //when cell is clicked naviagte to details page and send the data along with it
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "DetailScreen", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "dscreen") as? DetailScreen else {
            return
        }
        
        let selectedTask = tasks[indexPath.row]
        detailViewController.task = selectedTask
        
        let storyboard1 = UIStoryboard(name: "DetailScreen", bundle: nil)
        if let detailScreenViewController = storyboard1.instantiateViewController(withIdentifier: "dscreen") as? UIViewController {
            detailScreenViewController.modalPresentationStyle = .overFullScreen
            self.present(detailScreenViewController, animated: true, completion: nil)
        }
        print("selected task: ",selectedTask)
        
    }
    
    
}
