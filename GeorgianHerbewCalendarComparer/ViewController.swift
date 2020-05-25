//
//  ViewController.swift
//  GeorgianHerbewCalendarComparer
//
//  Created by Vardges Gasparyan on 2020-05-24.
//  Copyright © 2020 Vardges Gasparyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var dayString = ""
    var monthString = ""
    var yearString = ""
    
    var hebrewYear = ""
    var hebrewMonth = ""
    var hebrewDay = ""
    var hebrew = ""
    var events = ["", ""]

    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var hebrewEventsLabel: UILabel!
    @IBOutlet weak var hebrewYearLabel: UILabel!
    @IBOutlet weak var hebrewMonthLabel: UILabel!
    @IBOutlet weak var hebrewLabel: UILabel!
    @IBOutlet weak var hebrewDayLabel: UILabel!
    
    @IBAction func showResultButton(_ sender: Any) {
        
        jsonParse()
    }
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDatePicker()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }

     func showDatePicker() {
       //Formate Date
        datePicker.datePickerMode = .date

      //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker

    }
    
     @objc func donedatePicker() {

        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let day: String = formatter.string(from: self.datePicker.date)
        dayString = day
        formatter.dateFormat = "MM"
        let month: String = formatter.string(from: self.datePicker.date)
        monthString = month
        formatter.dateFormat = "yyyy"
        let year: String = formatter.string(from: self.datePicker.date)
        yearString = year
        formatter.dateFormat = "\(day)/\(month)/\(year)"
        dateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    

    @objc func cancelDatePicker() {
        self.view.endEditing(true)
     }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        
        self.view.frame.origin.y = -225
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func jsonParse() {
        
        let urlString = "https://www.hebcal.com/converter/?cfg=json&gy=\(yearString)&gm=\(monthString)&gd=\(dayString)&g2h=1"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            DispatchQueue.main.async {
                
                if let err = err {

                    print("Failed to get data from URL", err)
                    return
                }
                guard let jsonData = data else { return }
                
                do{
                    
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        
                        print(json)
                        if let yearReasult = json["hy"] as? Int {
                            self.hebrewYear = String(yearReasult)
                            print("The hebrew year is: \(self.hebrewYear)")
                            self.hebrewYearLabel.text = self.hebrewYear
                        }
                        if let monthReasult = json["hm"] as? String {
                            self.hebrewMonth = monthReasult
                            print("The hebrew month is: \(self.hebrewMonth)")
                            self.hebrewMonthLabel.text = self.hebrewMonth
                        }
                        if let dayReasult = json["hd"] as? Int {
                            self.hebrewDay = String(dayReasult)
                            print("The hebrew day is: \(self.hebrewDay)")
                            self.hebrewDayLabel.text = self.self.hebrewDay
                        }
                        if let hebrewReasult = json["hebrew"] as? String {
                            self.hebrew = hebrewReasult
                            print("Which is on hebrew: \(self.hebrew)")
                            self.hebrewLabel.text = self.hebrew
                        }
                        if let eventsReasult = json["events"] as? Array<String> {
                            self.events.removeAll()
                            self.events.append(contentsOf: eventsReasult)
                            print("Todays events is: \(self.events)")
                            self.hebrewEventsLabel.text = self.events.joined(separator: ", ")
                        }
                    }
                } catch {
                    
                    print(err?.localizedDescription ?? "Error Localize")
                }
            }
        } .resume()
        print("\(urlString)")
    }
}

