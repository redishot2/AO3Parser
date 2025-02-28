//
//  ParsingTests.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 2/28/25.
//

import XCTest
@testable import FanFictionAPI

class ParsingTests: XCTestCase {

    private enum Constants {
        static let mockAboutInfo = "MockAboutInfo"
        static let mockCategoryInfo = "MockCategoryInfo"
        static let mockChapterInfo = "MockChapterInfo"
        static let mockChapterListInfo = "MockChapterListInfo"
        static let mockFeedInfo = "MockFeedInfo"
        static let mockFilterInfo = "MockFilterInfo"
        static let mockNews = "MockNews"
        static let mockStoryInfo = "MockStoryInfo"
        static let mockUserInfo = "MockUserInfo"
    }
    
    private func getTestJSON(fileName: String) -> Data? {
        let bundle = Bundle(for: ParsingTests.self)
        if let path = bundle.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
    func testValidData() {
//        guard let data = getTestJSON(fileName: Constants.mockDataValid) else {
//            XCTFail("Local mock JSON not found")
//            return
//        }
//        
//        let result = Networking.handleResponse(data: data)
//        if case .success(let recipes) = result {
//            
//        } else {
//            XCTFail("Incorrect result type")
//        }
        XCTAssertEqual(1, 1)
    }
}
