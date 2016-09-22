//
//  ComposeViewController.swift
//  HitMe
//
//  Created by Swarup_Pattnaik on 20/09/16.
//  Copyright © 2016 Swarup_Pattnaik. All rights reserved.
//

import UIKit
import CoreData

class ComposeViewController: UIViewController {

    var textArray = NSMutableArray()
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var accessoryView: UIStackView!
    @IBOutlet weak var sendToField: UITextField!
    @IBOutlet var messageBodyField: UITextView!
    
    //MARK: - Button Actions
    @IBAction func sendMessage(sender: UIButton) {

        let toName = sendToField.text ?? "Tarun"
        let fromName = "Arun"
        // check for empty messages
        guard let bodytext = messageBodyField!.text where !messageBodyField!.text.isEmpty else {
            return
        }
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy HH:mm a"
        let text = dateFormat.stringFromDate(NSDate())
        let replyTime = NSDate().dateByAddingTimeInterval(5)
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let notification = appDelegate?.localNotification
        {
            notification.alertTitle = toName
            notification.alertBody = bodytext
            notification.soundName = "Default"
            notification.fireDate = replyTime
            notification.repeatInterval = NSCalendarUnit(rawValue: 0)
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.userInfo = ["body": String(bodytext.characters.reverse()), "toName":toName]
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
        
        
        let messageData : [String:AnyObject] = ["fromName":fromName, "text":bodytext, "toName":toName, "timeStamp": text, "flag" : true]
        
        textArray.addObject(messageData)
        
        tableView.reloadData()
        
        let splitViewController = self.presentingViewController as! UISplitViewController
        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.insertNewObject(messageData)


    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
       
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendToField.delegate = self
        sendToField.inputAccessoryView = accessoryView
        sendToField.keyboardType = .NamePhonePad
        messageBodyField.keyboardType = .Default
        sendToField.becomeFirstResponder()
//        tableView.addGestureRecognizer(self.tapRecognizer())

        
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
    
//    func tapRecognizer() -> UITapGestureRecognizer
//    {
//        
//        let tap = UITapGestureRecognizer.init(target: self, action: Selector(hideKeyboard()))
//        tap.numberOfTapsRequired = 1;
//        tap.numberOfTouchesRequired = 1;
//        
//        return tap;
//    }
//    
//    func hideKeyboard() {
//        sendToField.endEditing(true)
//        messageBodyField.endEditing(true)
//    }

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

extension ComposeViewController: UITableViewDelegate {
}

extension ComposeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print(textArray.count)
        return textArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCellWithIdentifier("messageData") as? CustomTableCell {
            let msgObj = textArray.objectAtIndex(indexPath.row) as! [String:AnyObject]
            if (((msgObj["flag"] as? Bool)) != true) {
                cell.toLabel.hidden = false
                cell.fromLabel.hidden = true

            }
            else{
                cell.toLabel.hidden = true
                cell.fromLabel.hidden = false

            }
            cell.date!.text = msgObj["timeStamp"] as? String
            cell.toLabel!.text = msgObj["toName"] as? String
            cell.fromLabel!.text = msgObj["fromName"] as? String
            cell.messageBody!.text = msgObj["text"] as? String
            
            print(cell.toLabel.text)
            print(cell.fromLabel.text)
            print(cell.messageBody.text)

            return cell

        }
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        return UITableViewCell();
    }

    

}

