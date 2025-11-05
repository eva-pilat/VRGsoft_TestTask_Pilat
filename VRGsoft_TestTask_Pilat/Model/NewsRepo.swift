//
//  NewsRepo.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 03.11.2025.
//

// apiKey = "3abe8f0789864a319bc5dace6d01c18b"

import Foundation

final class NewsRepo: NewsService {
    
    static let shared = NewsRepo()
    
    private init() {}
    private let networkLayer = NetworkRepo()
    
    func getNews(page: Int) async throws -> [Model.NewsArticle] {
        <#code#>
    }
    
    func getNewsByCategory(category: Model.NewsCategory, page: Int) async throws -> [Model.NewsArticle] {
        <#code#>
    }
    
    func addToFavorites(article: Model.NewsArticle) async throws {
        <#code#>
    }
    
    func removeFromFavorites(article: Model.NewsArticle) async throws {
        <#code#>
    }
    
    func getFavorites() async throws -> [Model.NewsArticle] {
        <#code#>
    }
    
    
}
