////
////  Favorites.swift
////  FanFictionAPI
////
////  Created by Natasha Martinez on 2/28/25.
////
//
//import Foundation
//
//struct Favorites {
//    static var shared = Favorites()
//    
//    private enum Constants {
//        static let favoriteWorks = "favoriteWorks"
//        static let favoriteAuthors = "favoriteAuthors"
//    }
//    
//    private(set) var authors: [CircleDisplay] {
//        didSet {
//            if let encoded = try? JSONEncoder().encode(authors) {
//                UserDefaults.standard.set(encoded, forKey: Constants.favoriteAuthors)
//            }
//        }
//    }
//    
//    private(set) var works: [SaveObject] {
//        didSet {
//            if let encoded = try? JSONEncoder().encode(works) {
//                UserDefaults.standard.set(encoded, forKey: Constants.favoriteWorks)
//            }
//        }
//    }
//    
//    init() {
//        if let data = UserDefaults.standard.object(forKey: Constants.favoriteWorks) as? Data, let progress = try? JSONDecoder().decode([SaveObject].self, from: data) {
//            self.works = progress
//        } else {
//            self.works = []
//        }
//        
//        if let data = UserDefaults.standard.object(forKey: Constants.favoriteAuthors) as? Data, let progress = try? JSONDecoder().decode([CircleDisplay].self, from: data) {
//            self.authors = progress
//        } else {
//            self.authors = []
//        }
//    }
//}
//
//// MARK: Author accessors
//extension Favorites {
//    static func favorite(author: CircleDisplay) {
//        shared.authors.append(author)
//    }
//    
//    static func unfavorite(author: CircleDisplay) {
//        shared.authors.removeAll(where: { $0.name == author.name })
//    }
//    
//    static func toggleFavorite(author: CircleDisplay) {
//        if isFavorited(author: author.name) {
//            unfavorite(author: author)
//        } else {
//            favorite(author: author)
//        }
//    }
//    
//    static func isFavorited(author: String) -> Bool {
//        let favoritedAuthor = shared.authors.first(where: { $0.name == author })
//        
//        return favoritedAuthor != nil
//    }
//}
//
//// MARK: Work accessors
//extension Favorites {
//    static func favorite(work: SaveObject) {
//        shared.works.append(work)
//    }
//    
//    static func unfavorite(work: SaveObject) {
//        shared.works.removeAll(where: { $0.feedCardInfo.workID == work.feedCardInfo.workID })
//    }
//    
//    static func toggleFavorite(work: SaveObject) {
//        if isFavorited(workID: work.feedCardInfo.workID) {
//            unfavorite(work: work)
//        } else {
//            favorite(work: work)
//        }
//    }
//    
//    static func isFavorited(workID: String) -> Bool {
//        let favoritedWork = shared.works.first(where: { $0.feedCardInfo.workID == workID })
//        
//        return favoritedWork != nil
//    }
//}
//
//struct CircleDisplay: Codable, Hashable, Identifiable {
//    var id = UUID()
//    var name: String
//    var localizedKey: String?
//    var image: String
//}
