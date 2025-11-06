//
//  CoreDataRepo.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 05.11.2025.
//
import Foundation
import CoreData

protocol DBService {
    func saveArticle(article: Model.NewsArticle) async throws
    func deleteArticle(id: String) async throws
    func fetchArticles() async throws -> [Model.NewsArticle]
    func isArticleFavorite(id: String) async throws -> Bool
}

final class CoreDataDBService: DBService {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveArticle(article: Model.NewsArticle) async throws {
        let managed = NewsArticle(context: context)
        
        managed.idURL = article.id
        managed.title = article.title
        managed.text = article.text
        managed.imageURL = article.imageURL?.absoluteString
        managed.sourceName = article.sourceName
        managed.isFavorite = true
        
        try context.save()
    }
    
    func deleteArticle(id: String) async throws {
        
    }
    
    func fetchArticles() async throws -> [Model.NewsArticle] {
        
    }
    
    func isArticleFavorite(id: String) async throws -> Bool{
        
    }
}
