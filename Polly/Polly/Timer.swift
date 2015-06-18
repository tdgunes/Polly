//
//  Timer.swift
//  Polly
//
//  Created by Taha Doğan Güneş on 17/06/15.
//  Copyright (c) 2015 Taha Doğan Güneş. All rights reserved.
//

import Foundation


class Timer {
    typealias Operation = ()->()
    

    let interval:Int
    let operation:Operation
    let tickOperation:Operation

    var mustContinue = true
    var elapsedTime:Int
    
    init(interval:Int, operation:Operation, tickOperation:Operation){
        println("Timer is initialized.")
        self.interval = interval
        self.operation = operation
        self.tickOperation = tickOperation
        self.elapsedTime = 0
    }
    
    func tick() {
        sleep(1)
        if mustContinue {
            dispatch_async(dispatch_get_main_queue(), {
                self.tickOperation()
                if(self.elapsedTime >= self.interval){
                    self.operation()
                    self.elapsedTime = 0
                }
                else {
                    self.elapsedTime++
                }
                return
            })
        }
    }
    
    func start() {
        self.mustContinue = true
        println("Timer is started.")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            while self.mustContinue {
                sleep(1)
                self.tick()
            }
        })
    }
    
    func stop() {
        mustContinue = false

    }
    
}