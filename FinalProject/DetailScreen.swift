//
//  DetailScreen.swift
//  FinalProject
//
//  Created by apple on 26/03/2024.
//

import UIKit

class DetailScreen: UIViewController {
    
    //initialize iboutlet
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskTypeField: UITextField!
    @IBOutlet weak var assigneeField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var taskStatusPicker: UISegmentedControl!
    let taskStatuses = ["Not Started", "In Progress", "Completed"]
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskStatusPicker.removeAllSegments()
        //adding the 3 segment view here
        taskStatusPicker.insertSegment(withTitle: "Not Started", at: 0, animated: false)
        taskStatusPicker.insertSegment(withTitle: "In Progress", at: 1, animated: false)
        taskStatusPicker.insertSegment(withTitle: "Completed", at: 2, animated: false)
        
        //setting up the picker
        taskStatusPicker.selectedSegmentIndex = 0
        
        //initialize the date picker
        datePicker.date = Date()
        
        populateTaskDetails()
    }
    //populates the tasks inside the fields in the details page
    func populateTaskDetails() {
        guard let task = task else {
            return
        }
        
        taskNameField.text = task.title as? String ?? ""
        assigneeField.text = task.icon_name as? String ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let completedByString = task.date_completed as? String,
           let completedByDate = dateFormatter.date(from: completedByString) {
            datePicker.date = completedByDate
        } else {
            datePicker.date = Date()
        }
        
    }
    //saves the tasks simply calls the savetask function
    @IBAction func save(_ sender: Any) {
        saveTask()
    }
    //naviagtion
    @IBAction func back(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TableView", bundle: nil)
        if let detailScreenViewController = storyboard.instantiateViewController(withIdentifier: "tableView") as? UIViewController {
            detailScreenViewController.modalPresentationStyle = .fullScreen
            self.present(detailScreenViewController, animated: true, completion: nil)
        }
        print("not working")
    }
    //save task function using userdefaults as the way of saving locally
    func saveTask() {
        var tasks = UserDefaults.standard.array(forKey: "tasks") as? [[String: Any]] ?? []
        
        //print(tasks)
        
        let taskData: [String: Any] = [
            "taskName": taskNameField.text ?? "",
            "taskType": taskTypeField.text ?? "",
            "taskStatus": taskStatuses[taskStatusPicker.selectedSegmentIndex],
            "assignee": assigneeField.text ?? "",
            "taskDate": datePicker.date
        ]
        tasks.append(taskData)
        
        UserDefaults.standard.set(tasks, forKey: "tasks")
        
        let savedData = UserDefaults.standard.dictionaryRepresentation()
        for (key, value) in savedData {
            print("Key: \(key), Value: \(value)")
        }
        
        let alert = UIAlertController(title: "Success", message: "Task details saved successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
//required methods for picker
extension DetailScreen: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return taskStatuses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return taskStatuses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
}

