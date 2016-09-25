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
    
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func scrollToBottom () {
        var yOffset : CGFloat = 0;
    
        if tableView.contentSize.height > tableView.bounds.size.height {
            yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
        }
        
        tableView.setContentOffset(_:CGPointMake(0, yOffset), animated: true)
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let objectsArray = self.detailItem as? [NSManagedObject] {
            //Populate Text Array
            for item in objectsArray {
                let toName = item.valueForKey("toName")!.description
                let fromName = item.valueForKey("fromName")!.description
                let bodytext = item.valueForKey("text")!.description
                let isSent = item.valueForKey("isSent")!.description
//                print("flagggggg \(flag)")
                let date = item.valueForKey("timeStamp")!.description

                let messageData : [String:AnyObject] = ["fromName":fromName, "text":bodytext, "toName":toName, "timeStamp": date, "isSent" : NSString(string: isSent).boolValue]
                
                textArray.addObject(messageData)
            }
        }
    }
    
    func updateView(notification: NSNotification) {
        if let userInfo = notification.userInfo as! [String : AnyObject]? {
            if let msgObj = userInfo ["messageData"] as! [String : AnyObject]? {
                
                guard let toName = msgObj["toName"] as? String where NSString(string: toName).isEqualToString(self.title!) else {
                return
                }
                let fromName = msgObj["fromName"] as? String
                let text = msgObj["text"] as? String
                let isSent = msgObj["isSent"] as? Bool
                let date = msgObj["timeStamp"] as? String


                let messageData : [String:AnyObject] = ["fromName":fromName!, "text":text!, "toName":toName, "timeStamp": date!, "isSent" : isSent!]
                
                textArray.addObject(messageData)
                tableView.reloadData()
                scrollToBottom() //Working
            }
        }
    }

    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
//            scrollToBottom() Not Working
        }
    }
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
        if let notification = appDelegate?.localNotification
        {
            notification.alertTitle = toName
            notification.alertBody = bodytext
            notification.soundName = "Default"
            notification.fireDate = replyTime
            notification.repeatInterval = NSCalendarUnit(rawValue: 0)
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.userInfo = ["body": String(bodytext.characters.reverse()), "toName":toName, "fromName":fromName, "isSent" : false]
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
        
        
        let messageData : [String:AnyObject] = ["fromName":fromName, "text":bodytext, "toName":toName, "timeStamp": date, "isSent" : true]
        //Persistence
        appDelegate!.controller.insertNewObject(messageData)
        
        textArray.addObject(messageData)
        
        tableView.reloadData()
        
        scrollToBottom() // Working
    }
    
    //MARK: - Button Actions
    @IBAction func cancelMessage(sender: UIButton) {
        messageBodyField.resignFirstResponder()
        messageBodyField.text = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        messageBodyField.keyboardType = .Default
//        scrollToBottom() Not Working
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateView(_:)), name: "UpdateDetailViewNotification", object: appDelegate)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UpdateDetailViewNotification", object: appDelegate)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        messageBodyField.becomeFirstResponder()
//      scrollToBottom() Not Working
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        scrollToBottom() // Working
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
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
            let boolType = msgObj["isSent"] as! NSNumber
            if (boolType.boolValue) {
                cell.toLabel.hidden = true
                cell.fromLabel.hidden = false
                cell.messageBody!.backgroundColor = UIColor.yellowColor()
            }
            else{
                cell.toLabel.hidden = false
                cell.fromLabel.hidden = true
                cell.messageBody!.backgroundColor = UIColor.orangeColor()
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
        return UITableViewCell();
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let msgObj = textArray.objectAtIndex(indexPath.row) as! [String:AnyObject]
            let fetchRequest = NSFetchRequest(entityName: "Message")
            fetchRequest.predicate = NSPredicate(format: "toName == %@ and fromName == %@ and timeStamp == %@ and text == %@ and isSent == %@", argumentArray: [msgObj["toName"]!,msgObj["fromName"]!,msgObj["timeStamp"]!,msgObj["text"]!,(msgObj["isSent"]?.boolValue)!])
            
            appDelegate!.controller.deleteObjectForFetchRequest(fetchRequest)
            
            textArray.removeObjectAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }

}




