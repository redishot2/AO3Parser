//
//  Logging.swift
//  AO3Scraper
//
//  Created by Natasha Martinez on 5/5/25.
//

public struct Logging {
    public static func log(_ message: String) {
        print(message)
    }
    
    public static func log(_ error: Error) {
        print("Failed with error: \(error)")
    }
}
