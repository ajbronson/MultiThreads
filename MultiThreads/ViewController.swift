//
//  ViewController.swift
//  MultiThreads
//
//  Created by AJ Bronson on 6/21/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UserQueueChanged {
    
    @IBOutlet weak var pushThreadCountLabel: UILabel!
    @IBOutlet weak var objectQueueCountLabel: UILabel!
    @IBOutlet weak var pullThreadCountLabel: UILabel!
    @IBOutlet weak var queueActivityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var pushThreadCount: Int = 0
    var pullThreadCount: Int = 0
    var objectCount = 0
    var addingThreads = [NSOperationQueue]()
    var removingThreads = [NSOperationQueue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set initial label values
        updatePullThreadCountLabel()
        updatePushThreadCountLabel()
        objectQueueCountLabel.text = "0"
        queueActivityLabel.text = ""
        
        //assign delegate to self
        UserController.sharedController.delegate = self
    }
    
    //MARK: - UserQueueChanged Protocol
    
    //protocol conformance method to update total objects on the UI
    func currentUserQueueCount(totalObjects: Int) {
        updateActivityLabel(objectCount, currentCount: totalObjects)
        objectQueueCountLabel.text = "\(totalObjects)"
        objectCount = totalObjects
    }
    
    //MARK: - Update UI Thread Count
    
    func updatePushThreadCountLabel() {
        pushThreadCountLabel.text = "\(pushThreadCount)"
    }
    
    func updatePullThreadCountLabel() {
        pullThreadCountLabel.text = "\(pullThreadCount)"
    }
    
    //activity label
    func updateActivityLabel(previousCount: Int, currentCount: Int) {
        if currentCount > previousCount {
            queueActivityLabel.text = "Object Added!"
            delay(1.0, closure: {
                self.queueActivityLabel.text = ""
            })
        } else if currentCount < previousCount {
            queueActivityLabel.text = "Object Removed"
            delay(1.0, closure: {
                self.queueActivityLabel.text = ""
            })
        }
    }
    
    //MARK: - Buttons Tapped
    
    //push thread
    @IBAction func pushButtonTapped(sender: UIButton) {
        
        //update the push thread label
        pushThreadCount += 1
        updatePushThreadCountLabel()
        
        //create queue and add operation to it
        let operationQueue = NSOperationQueue()
        let operation = AddObjectOperation()
        
        //upon completion, update the push thread label, remove the object from the tableview
        operation.completionBlock = {
            
            dispatch_async(dispatch_get_main_queue(), {
                self.pushThreadCount -= 1
                self.updatePushThreadCountLabel()
                
                if let index = self.addingThreads.indexOf(operationQueue) {
                    let indexPath = NSIndexPath(forItem: self.addingThreads.count - 1, inSection: 0)
                    self.addingThreads.removeAtIndex(index)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            })
        }
        
        operationQueue.addOperation(operation)
        addingThreads.append(operationQueue)
        let index = NSIndexPath(forRow: addingThreads.count - 1, inSection: 0)
        tableView.insertRowsAtIndexPaths([index], withRowAnimation: .Left)
        
    }
    
    //pull thread
    @IBAction func pullButtonTapped(sender: UIButton) {
        pullThreadCount += 1
        updatePullThreadCountLabel()
        
        let operationQueue = NSOperationQueue()
        let operation = RemoveObjectOperation()
        operation.completionBlock = {
            
            dispatch_async(dispatch_get_main_queue(), {
                self.pullThreadCount -= 1
                self.updatePullThreadCountLabel()
                
                if let index = self.removingThreads.indexOf(operationQueue) {
                    let indexPath = NSIndexPath(forItem: self.removingThreads.count - 1, inSection: 1)
                    self.removingThreads.removeAtIndex(index)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            })
        }
        
        operationQueue.addOperation(operation)
        removingThreads.append(operationQueue)
        let index = NSIndexPath(forRow: removingThreads.count - 1, inSection: 1)
        tableView.insertRowsAtIndexPaths([index], withRowAnimation: .Left)
    }
    
    
    //MARK: - Delay Function
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), closure)
    }
    
}

//MARK: - TableView Extension
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Adding Threads"
        } else {
            return "Removing Threads"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return addingThreads.count
        } else {
            return removingThreads.count
        }
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("threadCell", forIndexPath: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = "Adding Thread"
        } else {
            cell.textLabel?.text = "Removing Thread"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.section == 0 {
                let operationQueue = addingThreads[indexPath.row]
                operationQueue.operations[0].cancel()
                addingThreads.removeAtIndex(indexPath.row)
            } else {
                let operationQueue = removingThreads[indexPath.row]
                operationQueue.operations[0].cancel()
                removingThreads.removeAtIndex(indexPath.row)
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}


