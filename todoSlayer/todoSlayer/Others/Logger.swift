//
//  Logger.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 26/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation

enum CommonLogs: String {
    case nilSnapshot = "Snapshot is nil!"
    case typecastFailed = "Typecasting failed!"
}

class Logger {
    
    // dummy just to differentiate method signatures
    private static func log(reason: String,
                            lineNumber: Int = #line,
                            fileName: String = #file,
                            functionName: String = #function,
                            dummy: Int?) {
        
        let normalLog =  """
        
        <------------ LOG MESSAGE -------------->
        
        File: \(fileName)
        Function: \(functionName)
        Line: \(lineNumber)
        
        
        REASON: \(reason)
        
        <---------------------------------------->
        """
        
        print(normalLog)
    }
    
    static func log(reason: String) {
        log(reason: reason, dummy: nil)
    }
    
    static func log(_ error: Error) {
        log(reason: error.localizedDescription, dummy: nil)
    }
    
    static func log(_ commonLog: CommonLogs, reason: String = "") {
        self.log(reason: commonLog.rawValue + " \(reason)")
    }
}
