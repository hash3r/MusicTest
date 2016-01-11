//
//  SelectionGenreController.swift
//  MusicTest
//
//  Created by Vladimir Gnatiuk on 1/11/16.
//  Copyright © 2016 Vladimir Gnatiuk. All rights reserved.
//

import UIKit

enum Instruments: Int {
    case Bass = 1
    case ElectricGuitar = 2
    case Guitar = 3
    case Banjo = 4
    
    func description() -> String {
        switch self {
        case Guitar: return "Guitar"
        case Banjo: return "Banjo"
        case Bass: return "Bass"
        case ElectricGuitar: return "Electric guitar"
        }
    }
}

class SelectionGenreController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var instrumentsButtons: [UIButton]!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var selectedInstrument: Instruments?
    var userName: String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Type your name here", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showResult" {
            let vc = segue.destinationViewController as! ResultController
            vc.userName = userName
            vc.selectedInstrument = selectedInstrument
        }
    }
    
    @IBAction func selectedInstrumentAction(sender: UIButton) {
        for button in instrumentsButtons {
            button.layer.borderWidth = 0
        }
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor.redColor().CGColor
        selectedInstrument = Instruments.init(rawValue: sender.tag)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard let name = textField.text  else { return }
        if name.isEmpty {
            showAlertWithTitle("Error", message: "Please type your name")
        } else if let selectedInstrument = selectedInstrument {
            RestAPI.sharedInstance.submittPoll(name, selection: selectedInstrument.description(), success: { (json) -> () in
                self.userName = name
                self.performSegueWithIdentifier("showResult", sender: textField)
            }, failure: { (error) -> () in
                self.showAlertWithTitle("Error", message: error!.localizedDescription)
            })
        } else {
            showAlertWithTitle("Error", message: "Please select an instrument before submitting poll")
        }
    }
    
    func showAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default) { (alert: UIAlertAction!) -> Void in }
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion:nil)
    }

}
