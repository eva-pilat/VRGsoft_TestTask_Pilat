//
//  NewsArticle+CoreDataProperties.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 06.11.2025.
//
//

public import Foundation
public import CoreData


public typealias NewsArticleCoreDataPropertiesSet = NSSet

extension NewsArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsArticle> {
        return NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
    }

    @NSManaged public var title: String?
    @NSManaged public var text: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var sourceName: String?
    @NSManaged public var idURL: String?

}

extension NewsArticle : Identifiable {

}
