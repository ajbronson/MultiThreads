//
//  UserController.swift
//  MultiThreads
//
//  Created by AJ Bronson on 6/22/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation


class UserController {
    
    static let sharedController = UserController()
    
    var delegate: UserQueueChanged?
    
    //create thread-safe user queue
    class var singletonUserQueue: [User] {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: [User]? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = [User]()
        }
        return Static.instance!
    }
    
    //assign thread safe queue to property that will be accessed through the UserController's singleton
    //when the queue changes, call the delegate to update the total object label on the UI
    var sharedUserQueue = singletonUserQueue {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.currentUserQueueCount(self.sharedUserQueue.count)
            }
        }
    }
    
    //add object to queue, blocking any maniuplation until this operation is complete
    func addUser(user: User) {
        
        dispatch_barrier_async(Queue.concurrentQueue) {
            self.sharedUserQueue.append(user)
        }
    }
    
    //remove object from the queue, blocking any maniuplation until this operation is complete
    func removeUser() {
        dispatch_barrier_async(Queue.concurrentQueue) {
            self.sharedUserQueue.removeLast()
        }
    }
}

//delegate protocol to update the total object label on the UI
protocol UserQueueChanged {
    func currentUserQueueCount(totalObjects: Int)
}