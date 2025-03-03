//
//  ProfileNetworking.swift
//  FanFictionAPI
//
//  Created by Natasha Martinez on 3/2/25.
//

public class ProfileNetworking {
    
    public init() { }
    
    /// Fetches the given user's profile
    /// - Parameter profilePage: the profile subpage to load
    /// - Returns: the news feed info
    public func fetch(_ username: String, profilePage: Networking.Endpoint.ProfilePages) async -> UserInfo? {
        let result: Result<UserInfo?, Error> = await Networking.fetch(.profile(username: username, page: profilePage))
        switch result {
            case .success(let userInfo):
                return userInfo
            case .failure:
                // TODO: error handling
                return nil
        }
    }
}
