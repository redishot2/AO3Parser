//
//  String+Utilities.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

extension String {
    func webFriendly() -> String {
        var encoded = self
        encoded = encoded.replacingOccurrences(of: ".", with: "*d*")
        encoded = encoded.replacingOccurrences(of: "&", with: "*a*")
        
        return encoded
    }
    
    public func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
    
    internal func toInt() -> Int? {
        let formater = NumberFormatter()
        formater.numberStyle = .decimal
        formater.locale = Locale(identifier: Locale.current.identifier)
        let number = formater.number(from: self)
        
        return number?.intValue
    }
}
