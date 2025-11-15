//
//  NewsTableViewCell.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 05.11.2025.
//

import UIKit
import Foundation
import SDWebImage

protocol ArticleCellDelegate: AnyObject {
    func didToggleFavorite(article: Model.NewsArticle)
}

class NewsTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(articleTitleLabel)
        contentView.addSubview(articleDescriptionLabel)
        contentView.addSubview(articleImageView)
        contentView.addSubview(saveButton)
        
        setupLayout()
        updateBookmark()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder has not been implemented")
    }
    
    private var articleTitleLabel = UILabel()
    private var articleDescriptionLabel = UILabel()
    private var articleImageView = UIImageView()
    private var saveButton = UIButton()
    
    private var article: Model.NewsArticle?
    weak var delegate: ArticleCellDelegate?
    private var isToggling = false
    
    private func configureImageView() {
        articleImageView.translatesAutoresizingMaskIntoConstraints = false
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true
        articleImageView.layer.cornerRadius = 10
        articleImageView.image = UIImage(named: "defaultik")
    }
    
    private func configureDescriptionLabel() {
        articleDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        articleDescriptionLabel.numberOfLines = 0
        articleDescriptionLabel.lineBreakMode = .byWordWrapping
        articleDescriptionLabel.adjustsFontSizeToFitWidth = false
    }
    
    private func configureLabel() {
        articleTitleLabel.font = .preferredFont(forTextStyle: .headline)
        articleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        articleTitleLabel.numberOfLines = 1
        articleTitleLabel.lineBreakMode = .byTruncatingTail
    }
    
    private func configureSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        saveButton.tintColor = .label
        saveButton.addTarget(self, action: #selector(onSaveButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func setupLayout() {
        configureLabel()
        configureDescriptionLabel()
        configureImageView()
        configureSaveButton()
     
        NSLayoutConstraint.activate([
            articleTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articleTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            articleTitleLabel.heightAnchor.constraint(equalToConstant: 21),
            
            articleDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articleDescriptionLabel.topAnchor.constraint(equalTo: articleTitleLabel.bottomAnchor, constant: 4),
            articleDescriptionLabel.widthAnchor.constraint(equalToConstant: 300),
            
            articleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            articleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            articleImageView.topAnchor.constraint(equalTo: articleDescriptionLabel.bottomAnchor, constant: 8),
            articleImageView.heightAnchor.constraint(equalToConstant: 110),
            
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            saveButton.leadingAnchor.constraint(greaterThanOrEqualTo: articleTitleLabel.trailingAnchor, constant: 8),
            saveButton.widthAnchor.constraint(equalToConstant: 44),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        article = nil
        articleTitleLabel.text = nil
        articleDescriptionLabel.text = nil
        articleImageView.image = nil
        saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        saveButton.tintColor = .label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBookmark()
    }
    
    func configure(with article: Model.NewsArticle, delegate: ArticleCellDelegate?) {
        self.article = article
        self.delegate = delegate
        
        articleTitleLabel.text = article.title
        articleDescriptionLabel.text = article.text
        articleImageView.sd_setImage(with: article.imageURL)
        
        updateBookmark()
    }
    
    func updateFavoriteStatus() {
        updateBookmark()
    }
    
    @objc func onSaveButtonTapped(_ sender: Any) {
        guard let article = article else { return }
        isToggling = true
        saveButton.isEnabled = false
        
        self.article?.isFavorite.toggle()
        updateBookmark()
        delegate?.didToggleFavorite(article: article)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isToggling = false
            self.saveButton.isEnabled = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func updateBookmark() {
        guard let article = article else { return }
        let imageName = (article.isFavorite == true) ? "bookmark.fill" : "bookmark"
        saveButton.setImage(UIImage(systemName: imageName), for: .normal)
        saveButton.tintColor = .label
    }
    
}

#if DEBUG
import SwiftUI

struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View
    
    init(_ builder: @escaping () -> View) {
        self.view = builder()
    }
    
    func makeUIView(context: Context) -> View {
        return view
    }
    
    func updateUIView(_ uiView: View, context: Context) {}
}

struct NewsTableViewCell_Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let cell = NewsTableViewCell(style: .default, reuseIdentifier: nil)
            cell.frame = CGRect(x: 0, y: 0, width: 375, height: 0)
            cell.layoutIfNeeded()
            return cell
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
