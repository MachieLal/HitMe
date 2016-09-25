//
//  MasterViewController.swift
//  HitMe
//
//  Created by Swarup_Pattnaik on 20/09/16.
//  Copyright © 2016 Swarup_Pattnaik. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    var messagesArray = NSMutableArray()// data model object
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(showComposeViewModally(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        autoreleasepool{updateTableView()}
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func showComposeViewModally(sender: AnyObject) {
        self.performSegueWithIdentifier("showComposeView", sender: sender)
    }
    
    func insertNewObject(message: [String:AnyObject]) {
        let context = self.managedObjectContext!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context)
             
        newManagedObject.setValue(message["timeStamp"] as? String, forKey: "timeStamp")
        newManagedObject.setValue(message["toName"] as? String, forKey: "toName")
        newManagedObject.setValue(message["fromName"] as? String, forKey: "fromName")
        newManagedObject.setValue(message["text"] as? String, forKey: "text")
        newManagedObject.setValue(message["isSent"] as? Bool, forKey: "isSent")

        // Save the context.
        do {
            try context.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    func updateTableView() {
        let fetchRequest = NSFetchRequest(entityName: "Message")
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = NSPredicate(format: "isSent == %@", argumentArray: [false])
        let sortedDate = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortedByName = NSSortDescriptor(key: "toName", ascending: true)

        fetchRequest.sortDescriptors = [sortedDate,sortedByName]
        fetchRequest.returnsObjectsAsFaults = false;
        
        var results : [AnyObject]? = nil
        // Fetch Request
        do {
            results = try self.managedObjectContext!.executeFetchRequest(fetchRequest)

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        messagesArray.removeAllObjects()
        if let objects = results as? [NSManagedObject] {
            if objects.count > 0 {
                var tempNameHolder = NSString(string: objects.first!.valueForKey("toName")!.description)
                let mutableObjectsArray = NSMutableArray(array: objects)
                while mutableObjectsArray.count != 0 {
                    tempNameHolder = NSString(string: mutableObjectsArray.firstObject!.valueForKey("toName")!.description)

                    guard let filteredArray = mutableObjectsArray.filteredArrayUsingPredicate(NSPredicate.init(format: "toName == %@", argumentArray: [tempNameHolder])) as [AnyObject]? where filteredArray.count > 0 else {
                        break
                    }
                    messagesArray.addObject(filteredArray.first!)
                    mutableObjectsArray.removeObjectsInArray(filteredArray)
                }
                
//                print("messages:::\(messagesArray)")
                tableView.reloadData()
            }
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let object = self.messagesArray[indexPath.row]
                
                let toName = object.valueForKey("toName")!.description
                let fromName = object.valueForKey("fromName")!.description
                let fetchRequest = NSFetchRequest(entityName: "Message")
                fetchRequest.fetchBatchSize = 20
                fetchRequest.predicate = NSPredicate(format: "toName == %@ and fromName == %@", argumentArray: [toName, fromName])
                let sortedDate = NSSortDescriptor(key: "timeStamp", ascending: true)
                fetchRequest.sortDescriptors = [sortedDate]
                fetchRequest.returnsObjectsAsFaults = false;

                var objects:AnyObject?
                // Fetch Request
                do {
                    let results = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
                    objects = results as! [NSManagedObject]
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }

                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = objects
                controller.title = toName
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
//        if segue.identifier == "showComposeView" {
//            
//        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messagesArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = messagesArray[indexPath.row] as! NSManagedObject
        self.configureCell(cell, withObject: object)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {

            let fetchRequest = NSFetchRequest(entityName: "Message")
            fetchRequest.fetchBatchSize = 20
            fetchRequest.predicate = NSPredicate(format: "toName == %@", argumentArray: [messagesArray[indexPath.row].valueForKey("toName")!.description])
            
            let batchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchRequest.resultType = .ResultTypeCount
            // Batch Delete Request
            do {
                let results = try self.managedObjectContext!.executeRequest(_:batchRequest)
                print("batchRequest result \(results)")
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            messagesArray.removeObjectAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }

    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        cell.textLabel!.text = object.valueForKey("toName")!.description
        cell.detailTextLabel!.text = object.valueForKey("text")!.description
    }
}