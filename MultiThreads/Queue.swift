//
//  Queue.swift
//  MultiThreads
//
//  Created by AJ Bronson on 6/22/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation

class Queue {
    
    static let concurrentQueue = dispatch_queue_create("userQueue", DISPATCH_QUEUE_CONCURRENT)
    
}