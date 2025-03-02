//
//  FanFictionAPITests.swift
//  FanFictionAPITests
//
//  Created by Natasha Martinez on 2/28/25.
//

import XCTest
@testable import FanFictionAPI

class FanFictionAPITests: XCTestCase {
    
    // MARK: Related Works
    func testFandomURLsSimple() async {
        let expectedURL = URL(string: "https://archiveofourown.org/tags/Felarya/works")
        let resultURL = Networking.generateURL(for: .relatedWorks(tag: "Felarya"))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testFandomURLsComplex() async {
        let expectedURL = URL(string: "https://archiveofourown.org/tags/Fairy%E8%98%AD%E4%B8%B8~%E3%81%82%E3%81%AA%E3%81%9F%E3%81%AE%E5%BF%83%E3%81%8A%E5%8A%A9%E3%81%91%E3%81%97%E3%81%BE%E3%81%99~%20%7C%20Fairy%20Ranmaru:%20Anata%20no%20Kokoro%20Otasuke%20Shimasu%20(Anime)/works")
        let resultURL = Networking.generateURL(for: .relatedWorks(tag: "Fairy蘭丸~あなたの心お助けします~ | Fairy Ranmaru: Anata no Kokoro Otasuke Shimasu (Anime)"))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    // MARK: Profile
    func testProfileURLsDashboard() async {
        let expectedURL = URL(string: "https://archiveofourown.org/users/Deuterium51614")
        let resultURL = Networking.generateURL(for: .profile(username: "Deuterium51614", page: .dashboard))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testProfileURLsProfile() async {
        let expectedURL = URL(string: "https://archiveofourown.org/users/Deuterium51614/profile")
        let resultURL = Networking.generateURL(for: .profile(username: "Deuterium51614", page: .profile))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testProfileURLsWorks() async {
        let expectedURL = URL(string: "https://archiveofourown.org/users/Deuterium51614/works")
        let resultURL = Networking.generateURL(for: .profile(username: "Deuterium51614", page: .works))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testProfileURLsSeries() async {
        let expectedURL = URL(string: "https://archiveofourown.org/users/Deuterium51614/series")
        let resultURL = Networking.generateURL(for: .profile(username: "Deuterium51614", page: .series))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testProfileURLsBookmarks() async {
        let expectedURL = URL(string: "https://archiveofourown.org/users/Deuterium51614/bookmarks")
        let resultURL = Networking.generateURL(for: .profile(username: "Deuterium51614", page: .bookmarks))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testProfileURLsCollections() async {
        let expectedURL = URL(string: "https://archiveofourown.org/users/Deuterium51614/collections")
        let resultURL = Networking.generateURL(for: .profile(username: "Deuterium51614", page: .collections))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testProfileURLsGifts() async {
        let expectedURL = URL(string: "https://archiveofourown.org/users/Deuterium51614/gifts")
        let resultURL = Networking.generateURL(for: .profile(username: "Deuterium51614", page: .gifts))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    // MARK: News
    func testNewsURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/admin_posts")
        let resultURL = Networking.generateURL(for: .newsfeed)

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    // MARK: Works
    func testWorkURLsOneShot() async {
        let expectedURL = URL(string: "https://archiveofourown.org/works/3234290?view_adult=true")
        let work = Work(id: "3234290")
        let resultURL = Networking.generateURL(for: .work(work: work, chapterID: nil))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testWorkURLsMultiChapter() async {
        let expectedURL = URL(string: "https://archiveofourown.org/works/22493011/chapters/53746540?view_adult=true")
        let work = Work(id: "22493011")
        let resultURL = Networking.generateURL(for: .work(work: work, chapterID: "53746540"))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    // MARK: Chapter List
    func testWorkChapterListURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/works/911674/navigate")
        let resultURL = Networking.generateURL(for: .workChapters(workID: "911674"))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    // MARK: Categories
    func testCategoriesAnimeURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Anime%20*a*%20Manga/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .anime))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesBooksURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Books%20*a*%20Literature/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .books))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesTVURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/TV%20Shows/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .tv))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesMoviesURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Movies/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .movies))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesGamesURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Video%20Games/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .games))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesCartoonsURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Cartoons%20*a*%20Comics%20*a*%20Graphic%20Novels/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .cartoons))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesCelebritiesURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Celebrities%20*a*%20Real%20People/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .celebrities))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesMusicURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Music%20*a*%20Bands/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .music))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesTheaterURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Theater/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .theater))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesUncategorizedURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Uncategorized%20Fandoms/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .uncategorized))

        XCTAssertEqual(expectedURL, resultURL)
    }
    
    func testCategoriesOtherURLs() async {
        let expectedURL = URL(string: "https://archiveofourown.org/media/Other%20Media/fandoms")
        let resultURL = Networking.generateURL(for: .category(name: .other))

        XCTAssertEqual(expectedURL, resultURL)
    }
}
