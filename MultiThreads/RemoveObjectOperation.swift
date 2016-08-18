//
//  RemoveObjectOperation.swift
//  MultiThreads
//
//  Created by AJ Bronson on 6/22/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation

class RemoveObjectOperation: NSOperation {
    
    override func main() {
        
        //if the operation hasn't been cancelled, and there are more than 0 user objects in the queue, remove them until there are 0,
        //or until the operation has executed 10 times, sleeping 3 minutes between each execution.
        for i in 0..<10 {
            if self.cancelled == false && UserController.sharedController.sharedUserQueue.count > 0 {
                UserController.sharedController.removeUser()
                if i != 9 {
                    sleep(3)
                }
            }
        }
    }
}