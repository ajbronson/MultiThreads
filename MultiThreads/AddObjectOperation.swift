//
//  AddObjectOperation.swift
//  MultiThreads
//
//  Created by AJ Bronson on 6/22/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation


class AddObjectOperation: NSOperation {
    
    var user = User(firstName: "AJ", lastName: "Bronson")
    
    override func main() {

        //If the operation hasn't been cancelled, add 10 user objects to the queue, waiting 2 seconds between each addition
        for i in 0..<10 {
            if self.cancelled == false {
                UserController.sharedController.addUser(user)
                if i != 9 {
                    sleep(2)
                }
            }
        }
    }
}