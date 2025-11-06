//
//  NewsTableViewCell.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 05.11.2025.
//

import UIKit
import Foundation
import SDWebImage

protocol ArticleCellDelegate: AnyObject{
    func didToggleFavorite(article: Model.NewsArticle)
}

class NewsTableViewCell: UITableViewCell {

    @IBOutlet private weak var articleTitle: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet weak var articleText: UITextView!
    @IBOutlet weak var articleImage: UIImageView!
    
    private var article: Model.NewsArticle?
    weak var delegate: ArticleCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        article = nil
        saveButton.setImage(nil, for: .normal)
        updateBookmark()
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBookmark()
    }
    
    func configure(with article: Model.NewsArticle, delegate: ArticleCellDelegate?){
        self.article = article
        self.delegate = delegate
        
        articleTitle.text = article.title
        articleText.text = article.text
        articleText.isUserInteractionEnabled = false
        articleText.isScrollEnabled = false
        articleText.textContainer.lineFragmentPadding = 0
        articleText.textContainerInset = .zero
        articleImage.sd_setImage(with: article.imageURL)
        
        updateBookmark()
        
    }
    
    func updateFavoriteStatus() {
        updateBookmark()
    }
    
    @IBAction func onSaveButtonTapped(_ sender: Any) {
        guard let article else {return}
        self.article?.isFavorite.toggle()
        delegate?.didToggleFavorite(article: article)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    private func updateBookmark(){
        guard let article else {return}
        let imageName = article.isFavorite ? "bookmark.fill" : "bookmark"
        saveButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

}
