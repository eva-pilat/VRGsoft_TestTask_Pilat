//
//  NewsRepo.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 03.11.2025.
//
import Foundation
import CoreData
import UIKit

final class NewsRepo: NewsService {
    
    static let shared = NewsRepo()
    private let networkLayer: NetworkService
    private let dbLayer: DBService
    
    private init() {
        self.networkLayer = AlamofireNetworkService()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dbLayer = CoreDataDBService(context: appDelegate.persistentContainer.viewContext)
    }
    
    func getNews(page: Int, search: String?) async throws -> [Model.NewsArticle] {
        let apiKey = "3abe8f0789864a319bc5dace6d01c18b"
        let url = URL(string: "https://newsapi.org/v2/everything")!
        let searchQuery = search ?? "Apple"
 
        let parameters: [String: Any] = [
            "q": searchQuery,
            "pageSize": 20,
            "page": page,
            "apiKey": apiKey
        ]

        let request = NetworkRequest(url: url, parameters: parameters)
        
        let response: NewsAPIResponse = try await networkLayer.request(request)
        
        let favorites: Set<String> = try await dbLayer.getFavoritesId()
     
        return response.articles.map { apiArticle in
            let isFav = favorites.contains(apiArticle.url)
            return Model.NewsArticle(id: apiArticle.url,
                                     title: apiArticle.title,
                                     text: apiArticle.description ?? "",
                                     imageURL: URL(string: apiArticle.urlToImage ?? ""),
                                     isFavorite: isFav,
                                     sourceName: apiArticle.source.name ?? "")
        }
    }
    
    func getNewsByCategory(category: Model.NewsCategory?, page: Int) async throws -> [Model.NewsArticle] {
        let apiKey = "3abe8f0789864a319bc5dace6d01c18b"
        let url = URL(string: "https://newsapi.org/v2/top-headlines")!
        let categoryQuery = category ?? Model.NewsCategory.general
 
        let parameters: [String: Any] = [
            "category": categoryQuery.rawValue,
            "page": page,
            "apiKey": apiKey
        ]

        let request = NetworkRequest(url: url, parameters: parameters)
        
        let response: NewsAPIResponse = try await networkLayer.request(request)
     
        return response.articles.map { apiArticle in
            return Model.NewsArticle(id: apiArticle.url,
                                     title: apiArticle.title,
                                     text: apiArticle.description ?? "",
                                     imageURL: URL(string: apiArticle.urlToImage ?? ""),
                                     isFavorite: false,
                                     sourceName: apiArticle.source.name ?? "")
        }
    }
    
    func addToFavorites(article: Model.NewsArticle) async throws {
        try await dbLayer.saveArticle(article: article)
    }
    
    func removeFromFavorites(article: Model.NewsArticle) async throws {
        try await dbLayer.deleteArticle(id: article.id)
    }
    
    func getFavorites() async throws -> [Model.NewsArticle] {
        return try await dbLayer.fetchArticles()
    }
    
    private struct NewsAPIResponse: Decodable {
        let status: String
        let totalResults: Int
        let articles: [NewsArticleAPI]
    }
    
    private struct NewsArticleAPI: Decodable {
        let source: Source
        let author: String?
        let title: String
        let description: String?
        let url: String
        let urlToImage: String?
        let publishedAt: String?
        let content: String?
    }
    
    private struct Source: Decodable {
        let id: String?
        let name: String?
    }
}


