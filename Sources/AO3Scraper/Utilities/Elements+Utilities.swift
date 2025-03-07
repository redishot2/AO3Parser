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
            
            guard let nsAttributedString = try? NSAttributedString(data: Data(rawHTML.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
                return nil
            }
            
            let attributedString = try? AttributedString(nsAttributedString, including: \.uiKit)
            
            return attributedString
//            let htmlData = NSString(string: rawHTML).data(using: String.Encoding.unicode.rawValue)
//            let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
//                    NSAttributedString.DocumentType.html]
//            let attributedString = try NSMutableAttributedString(data: htmlData ?? Data(), options: options, documentAttributes: nil)
//            
//            return AttributedString(attributedString)
        } catch {
            return nil
        }
    }
}
