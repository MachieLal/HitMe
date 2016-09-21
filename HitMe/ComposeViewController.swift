//
//  ComposeViewController.swift
//  HitMe
//
//  Created by Swarup_Pattnaik on 20/09/16.
//  Copyright © 2016 Swarup_Pattnaik. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet var accessoryView: UIStackView!
    @IBOutlet weak var sendToField: UITextField!
    
    @IBOutlet var messageBodyField: UITextView!
    @IBAction func sendMessage(sender: UIButton) {
        messageBodyField.text
    }
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
       
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendToField.delegate = self
        sendToField.inputAccessoryView = accessoryView
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ComposeViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    
        return true
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
    
    }

    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        return true
    }

    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
}
