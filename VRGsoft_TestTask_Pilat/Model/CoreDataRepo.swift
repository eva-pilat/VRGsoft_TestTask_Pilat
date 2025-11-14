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
    func getFavoritesId() async throws -> Set<String>
}

final class CoreDataDBService: DBService {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveArticle(article: Model.NewsArticle) async throws {
        try await context.perform {
            let managed = NewsArticle(context: self.context)
            
            managed.idURL = article.id
            managed.title = article.title
            managed.text = article.text
            managed.imageURL = article.imageURL?.absoluteString
            managed.sourceName = article.sourceName
            managed.isFavorite = true
            
            try self.context.save()
        }
    }
    
    func deleteArticle(id: String) async throws {
        try await context.perform {
            let fetchRequest: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "idURL == %@", id)
            
            do {
                let results = try self.context.fetch(fetchRequest)
                if let articleToDelete = results.first {
                    self.context.delete(articleToDelete)
                    try self.context.save()
                }
            } catch {
                throw error
            }
        }
    }
    
    func fetchArticles() async throws -> [Model.NewsArticle] {
        return try await context.perform {
            let request: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
            request.predicate = NSPredicate(format: "isFavorite == true")
            let results = try self.context.fetch(request)
            return results.map { article in
                Model.NewsArticle(id: article.idURL ?? "",
                                  title: article.title ?? "Без назви",
                                  text: article.text ?? "",
                                  imageURL: URL(string: article.imageURL ?? ""),
                                  isFavorite: true,
                                  sourceName: article.sourceName ?? "Невідоме джерело")
            }
        }
    }
    
    func getFavoritesId() async throws -> Set<String> {
        return try await context.perform {
            let request: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
            request.predicate = NSPredicate(format: "isFavorite == true")
            request.propertiesToFetch = ["idURL"]
            request.resultType = .managedObjectResultType
            let results = try self.context.fetch(request)
            let ids = results.compactMap { $0.idURL }
            return Set(ids)
        }
    }
}

