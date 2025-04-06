//
//  AttributedString+Utilities.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
import SwiftUI
import UIKit

extension AttributedString {
    
    public func convertToView() -> some View {
        var textUI = Text("")
        var alignment: Alignment = .leading
        
        let nsVersion = NSAttributedString(self)
        nsVersion.enumerateAttributes(in: NSRange(location: 0, length: nsVersion.length), options: []) { (attrs, range, _) in
            
            var textString = nsVersion.attributedSubstring(from: range).string
            if let link = attrs[NSAttributedString.Key.link] {
                textString = "[\(textString)](\(link))"
            }
            
            var t = Text(.init(textString))

            if let font = attrs[NSAttributedString.Key.font] as? UIFont {
                let traits = font.fontDescriptor.symbolicTraits

                
                if traits.contains(.traitItalic) {
                    t = t.italic()
                }
                
                if traits.contains(.traitBold) {
                    t = t.bold()
                }
            }
            
            if let paragraphStyle = attrs[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle {
                if paragraphStyle.alignment == .center {
                    alignment = .center
                } else if paragraphStyle.alignment == .right {
                    alignment = .trailing
                }
            }
            
            if let striked = attrs[NSAttributedString.Key.strikethroughStyle] as? NSNumber, striked != 0 {
                if let strikeColor = (attrs[NSAttributedString.Key.strikethroughColor] as? Color) {
                    t = t.strikethrough(true, color: strikeColor)
                } else {
                    t = t.strikethrough(true)
                }
            }
            
            if let underline = attrs[NSAttributedString.Key.underlineStyle] as? NSNumber, underline != 0 {
                if let underlineColor = (attrs[NSAttributedString.Key.underlineColor] as? Color) {
                    t = t.underline(true, color: underlineColor)
                } else {
                    t = t.underline(true)
                }
            }
            
            textUI = textUI + t
        }
        
        return textUI
            .frame(maxWidth: .infinity, alignment: alignment)
            .multilineTextAlignment(.leading)
    }
}
