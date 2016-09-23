//
//  DetailViewController.swift
//  HitMe
//
//  Created by Swarup_Pattnaik on 20/09/16.
//  Copyright © 2016 Swarup_Pattnaik. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    var textArray = NSMutableArray()

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let objectsArray = self.detailItem as? [NSManagedObject] {
            //Populate Text Array
            for item in objectsArray {
                let toName = item.valueForKey("toName")!.description
                let fromName = item.valueForKey("fromName")!.description
                let bodytext = item.valueForKey("text")!.description
                let flag = item.valueForKey("flag")!.description
//                print("flagggggg \(flag)")
                let date = item.valueForKey("timeStamp")!.description

                let messageData : [String:AnyObject] = ["fromName":fromName, "text":bodytext, "toName":toName, "timeStamp": date, "flag" : flag]
                
                textArray.addObject(messageData)
            }
        }
    }
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var accessoryView: UIStackView!
    @IBOutlet var messageBodyField: UITextView!
    
    //MARK: - Button Actions
    @IBAction func sendMessage(sender: UIButton) {
        
        let toName = self.title!
        let fromName = "Arun"
        // check for empty messages
        guard let bodytext = messageBodyField!.text where !messageBodyField!.text.isEmpty else {
            return
        }
        
        // Trigger a local notification for auto reply
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy HH:mm:ss a"
        let date = dateFormat.stringFromDate(NSDate())
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
            notification.userInfo = ["body": String(bodytext.characters.reverse()), "toName":toName, "fromName":fromName, "flag" : false]
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
        
        
        let messageData : [String:AnyObject] = ["fromName":fromName, "text":bodytext, "toName":toName, "timeStamp": date, "flag" : true]
        
        textArray.addObject(messageData)
        
        tableView.reloadData()
        
        //Persistence
        appDelegate!.controller.insertNewObject(messageData)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        messageBodyField.inputAccessoryView = accessoryView
//        textArray = NSMutableArray()
        // Do any additional setup after loading the view, typically from a nib.
//        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DetailViewController: UITableViewDelegate {
}

extension DetailViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        print(textArray.count)
        return textArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCellWithIdentifier("messageData") as? CustomTableCell {
            let msgObj = textArray.objectAtIndex(indexPath.row) as! [String:AnyObject]
            let boolType = NSString(string:msgObj["flag"]! as! String).boolValue
            if (boolType) {
                cell.toLabel.hidden = false
                cell.fromLabel.hidden = true
                cell.messageBody!.backgroundColor = UIColor.orangeColor()
            }
            else{
                cell.toLabel.hidden = true
                cell.fromLabel.hidden = false
                cell.messageBody!.backgroundColor = UIColor.yellowColor()

            }
            cell.date!.text = msgObj["timeStamp"] as? String
            cell.toLabel!.text = msgObj["toName"] as? String
            cell.fromLabel!.text = msgObj["fromName"] as? String
            cell.messageBody!.text = msgObj["text"] as? String
            
//            print(cell.toLabel.text)
//            print(cell.fromLabel.text)
//            print(cell.messageBody.text)
            
            return cell
            
        }
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        return UITableViewCell();
    }
}




