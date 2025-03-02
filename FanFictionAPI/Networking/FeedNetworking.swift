//
//  FeedNetworking.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 3/1/25.
//

class FeedNetworking {
    
    /// Fetches the news feed
    /// - Parameter page: what page of the endpoint to fetch (if there are multiple next pages)
    /// - Returns: the news feed info
    public func fetchNews(at page: Int = 0) async -> News? {
        let result: Result<News?, Error> = await Networking.fetch(.newsfeed)
        switch result {
            case .success(let news):
                return news
            case .failure:
                // TODO: error handling
                return nil
        }
    }
    
    /// Fetches the feed info for a given tag or fandom
    /// - Parameters:
    ///   - tag: the name of the feed to fetch
    ///   - page: what page of the endpoint to fetch (if there are multiple next pages)
    /// - Returns: the feed info
    private func fetchRelatedWorks(_ tag: String, page: Int = 0) async -> FeedInfo? {
        let result: Result<FeedInfo?, Error> = await Networking.fetch(.relatedWorks(tag: tag))
        switch result {
            case .success(let feed):
                return feed
            case .failure:
                // TODO: error handling
                return nil
        }
    }
    
    /// Fetches the category info for a given category
    /// - Parameters:
    ///   - tag: the name of the category to fetch
    ///   - page: what page of the endpoint to fetch (if there are multiple next pages)
    /// - Returns: the category info
    private func fetchCategory(_ category: Networking.Endpoint.Category, page: Int = 0) async -> CategoryInfo? {
        let result: Result<CategoryInfo?, Error> = await Networking.fetch(.category(name: category))
        switch result {
            case .success(let category):
                return category
            case .failure:
                // TODO: error handling
                return nil
        }
    }
}
