//
//  Model.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 03.11.2025.
//

import Foundation

enum Model{
    struct NewsArticle{
        var id: String
        var title: String
        var text: String
        var imageURL: URL?
        var isFavorite: Bool = false
    }
    
    enum NewsCategory: String, CaseIterable {
        case business, entertainment, general, health, science, sports, technology
    }
}

protocol NewsService {
    func getNews(page: Int) async throws -> [Model.NewsArticle]
    func getNewsByCategory(category: Model.NewsCategory, page: Int) async throws -> [Model.NewsArticle]
    func addToFavorites(article: Model.NewsArticle) async throws
    func removeFromFavorites(article: Model.NewsArticle) async throws
    func getFavorites() async throws -> [Model.NewsArticle]
}
