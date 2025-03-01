//
//  ParsingTests.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 2/28/25.
//

import XCTest
import SwiftSoup
@testable import FanFictionAPI

class ParsingTests: XCTestCase {

    private enum Constants {
        static let mockCategoryInfo = "MockCategoryInfo"
        static let mockChapterInfo = "MockChapterInfo"
        static let mockChapterListInfo = "MockChapterListInfo"
        static let mockFeedInfo = "MockFeedInfo"
        static let mockNews = "MockNews"
        static let mockUserInfo = "MockUserInfo"
    }
    
    private func getTestHTML(fileName: String) -> String? {
        let bundle = Bundle(for: ParsingTests.self)
        if let path = bundle.path(forResource: fileName, ofType: "json") {
            do {
                let data = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
                return data
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
    private func getMockData(fileName: String) -> Document? {
        guard let content = getTestHTML(fileName: fileName), !content.isEmpty else {
            return nil
        }
        
        guard let document = try? SwiftSoup.parse(content) else {
            return nil
        }
        
        return document
    }
    
    func testCategoryInfoParsing() async {
        guard let document = getMockData(fileName: Constants.mockCategoryInfo) else {
            XCTFail("Could not generate document from mock HTML")
            return
        }
        
        guard let category: CategoryInfo = await Networking.parseHTML(document: document, as: .category(name: .anime)) else {
            XCTFail("Could not parse mock HTML")
            return
        }
        
        XCTAssertTrue(!category.fandoms.isEmpty)
        XCTAssertNotNil(category.fandoms[0].name)
    }
    
    func testChapterListInfoParsing() async {
        guard let document = getMockData(fileName: Constants.mockChapterListInfo) else {
            XCTFail("Could not generate document from mock HTML")
            return
        }
        
        guard let chapterList: ChapterList = await Networking.parseHTML(document: document, as: .workChapters(workID: "2226570")) else {
            XCTFail("Could not parse mock HTML")
            return
        }
        
        XCTAssertTrue(!chapterList.chapters.isEmpty)
        XCTAssertNotNil(chapterList.chapters[0].name)
        XCTAssertNotNil(chapterList.chapters[0].url)
    }
    
    func testFeedParsing() async {
        guard let document = getMockData(fileName: Constants.mockFeedInfo) else {
            XCTFail("Could not generate document from mock HTML")
            return
        }
        
        let fandomName = "Fairy Tail"
        guard let feed: FeedInfo = await Networking.parseHTML(document: document, as: .relatedWorks(tag: fandomName)) else {
            XCTFail("Could not parse mock HTML")
            return
        }
        
        XCTAssertEqual(feed.filter.fandomName, fandomName)
        XCTAssertTrue(!feed.feedInfo.isEmpty)
        XCTAssertNotNil(feed.feedInfo[0].workID)
        XCTAssertNil(feed.feedInfo[0].stats.bookmarks)
        XCTAssertNotNil(feed.feedInfo[1].stats.bookmarks)
        XCTAssertEqual(feed.pagesCount, 1059)
        XCTAssertEqual(feed.filter.additionalTags.count, 10)
        XCTAssertEqual(feed.filter.categories.count, 6)
        XCTAssertEqual(feed.filter.characters.count, 10)
        XCTAssertEqual(feed.filter.fandoms.count, 10)
        XCTAssertEqual(feed.filter.languages.count, 138)
        XCTAssertEqual(feed.filter.ratings.count, 5)
        XCTAssertEqual(feed.filter.relationships.count, 10)
        XCTAssertEqual(feed.filter.warnings.count, 6)
    }
    
    func testNewsParsing() async {
        guard let document = getMockData(fileName: Constants.mockNews) else {
            XCTFail("Could not generate document from mock HTML")
            return
        }
        
        guard let news: News = await Networking.parseHTML(document: document, as: .newsfeed) else {
            XCTFail("Could not parse mock HTML")
            return
        }
        
        // Do more
        XCTAssertTrue(!news.articles.isEmpty)
        XCTAssertTrue(!news.tags.isEmpty)
        XCTAssertTrue(!news.translations.isEmpty)
        XCTAssertTrue(news.pagesCount > 0)
    }
    
    func testWorkParsing() async {
        guard let document = getMockData(fileName: Constants.mockChapterInfo) else {
            XCTFail("Could not generate document from mock HTML")
            return
        }
        
        let workEmpty = Work(id: "2226570")
        XCTAssertNil(workEmpty.currentChapter?.title)
        
        guard let work: Work = await Networking.parseHTML(document: document, as: .work(work: workEmpty, chapterID: "4884561")) else {
            XCTFail("Could not parse mock HTML")
            return
        }
        
        // Story Info
        XCTAssertEqual(work.storyInfo?.fandoms[0].name, "Fairy Tail")
        
        // About Info
        XCTAssertEqual(work.aboutInfo?.author.name, "Rhov")
        
        // Chapter Info
        XCTAssertEqual(work.currentChapter?.title.name, "Chapter 1: The Thunder God")
    }
    
    func testUserInfoParsing() async {
        guard let document = getMockData(fileName: Constants.mockUserInfo) else {
            XCTFail("Could not generate document from mock HTML")
            return
        }
        
        guard let userInfo: UserInfo = await Networking.parseHTML(document: document, as: .profile(username: "Rhov", page: .dashboard)) else {
            XCTFail("Could not parse mock HTML")
            return
        }
        
        XCTAssertTrue(!userInfo.recentWorks.isEmpty)
        XCTAssertTrue(!userInfo.recentSeries.isEmpty)
        XCTAssertTrue(!userInfo.recentBookmarks.isEmpty)
        XCTAssertTrue(!userInfo.fandoms.isEmpty)
//        XCTAssertTrue(!userInfo.gifts.isEmpty) // TODO: Fix
    }
}
