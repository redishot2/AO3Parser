//
//  CacheAsyncImage.swift
//  AO3Scraper
//
//  Created by Natasha Martinez on 3/3/25.
//

import SwiftUI

public struct CacheAsyncImage<Content>: View where Content: View {
    
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    public init(
        url: URL,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    public var body: some View {
        // Load image from cache or request
        if let cached = ImageCache[url] {
            content(.success(cached))
        } else {
            AsyncImage(url: url, scale: scale, transaction: transaction) { phase in
                cacheAndRender(phase: phase)
            }
        }
    }
    
    public func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success (let image) = phase {
            ImageCache[url] = image
        }
        
        return content(phase)
    }
}

fileprivate class ImageCache {
    @MainActor
    static private var cache: [URL: Image] = [:]
    
    @MainActor
    static subscript(url: URL) -> Image? {
        get {
            ImageCache.cache[url]
        } set {
            ImageCache.cache[url] = newValue
        }
    }
}
