//
//  CategoryInfoFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
internal import SwiftSoup

internal class CategoryInfoFactory {
    
    internal static func parse(_ document: Document?) -> CategoryInfo? {
        guard let document = document else { return nil }
        guard let metaItems = CategoryInfoFactory.getToCategoryInfoData(document) else { return nil }
        
        do {
            // Fandom groups
            let fandomGroupsRaw = try metaItems.select("ol").first(where: { $0.hasClass("alphabet fandom index group ") })
            guard let fandomsRaw = try fandomGroupsRaw?.select("li").filter({ $0.hasClass("letter listbox group")}) else { return nil }
            
            var fandoms: [FandomGroup] = []
            for fandom in fandomsRaw {
                if let fandomGroup = createFandomGroup(fandom) {
                    fandoms.append(fandomGroup)
                }
            }
            
            return CategoryInfo(fandoms: fandoms)
        } catch {
            return nil
        }
    }
    
    private static func getToCategoryInfoData(_ document: Document) -> Element? {
        guard let body = document.body() else { return nil }
        do {
            let divs = try body.select("div")
            let div = divs.first(where: { $0.id() == "outer" })
            
            return div
        } catch {
            return nil
        }
    }
    
    private static func createFandomGroup(_ fandom: Element) -> FandomGroup? {
        do {
            var fandomGroupName = ""
            if let fandomGroupNameRaw = try fandom.select("h3").first(where: { $0.hasClass("heading") })?.text() {
                fandomGroupName = fandomGroupNameRaw.replacingOccurrences(of: "↑", with: "")
                fandomGroupName = fandomGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            let fandomsRaw = try fandom.select("ul").select("li")
            
            var fandoms: [FandomItem] = []
            for fandomItemRaw in fandomsRaw {
                let fandomName = try fandomItemRaw.select("a").text()
                
                var worksCountRaw = try fandomItemRaw.text()
                worksCountRaw = worksCountRaw.replacingOccurrences(of: fandomName, with: "")
                worksCountRaw = worksCountRaw.replacingOccurrences(of: ")", with: "")
                worksCountRaw = worksCountRaw.replacingOccurrences(of: "(", with: "")
                worksCountRaw = worksCountRaw.trimmingCharacters(in: .whitespacesAndNewlines)
                let worksCount = Int(worksCountRaw)
                
                fandoms.append(FandomItem(name: fandomName, worksCount: worksCount ?? 0))
            }
            
            return FandomGroup(name: fandomGroupName, fandoms: fandoms)
        } catch {
            return nil
        }
    }
}
