//
//  Elements+Utilities.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup
import SwiftUI

extension Elements {
    
    /// Converts the element's raw HTML into a usable attributed string
    /// - Returns: converted HTML
    internal func attributedText() -> AttributedString? {
        var attributedString = AttributedString("")
        for element in self {
            if let singleLine = element.attributedText() {
                attributedString.append(singleLine)
            }
        }
        
        return attributedString
    }
}

extension Element {
    /// Converts the element's raw HTML into a usable attributed string
    /// - Returns: converted HTML
    internal func attributedText() -> AttributedString? {
        do {
            let rawHTML = try self.outerHtml()
            if rawHTML.contains("<img src=") {
                return nil 
            }

            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            guard let nsAttributedString = try? NSAttributedString(data: Data(rawHTML.utf8), options: options, documentAttributes: nil) else {
                return nil
            }
            
            let attributedString = try? AttributedString(nsAttributedString, including: \.uiKit)
            
            return attributedString
        } catch {
            return nil
        }
    }
}
