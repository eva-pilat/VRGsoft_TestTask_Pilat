//
//  ViewController.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 03.11.2025.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ArticleCellDelegate {
    
    private var news: [Model.NewsArticle] = []
    
    func didToggleFavorite(article: Model.NewsArticle) {
        Task {
            var updatedArticle = article
            updatedArticle.isFavorite.toggle()
                
            if updatedArticle.isFavorite {
                try? await NewsRepo.shared.addToFavorites(article: updatedArticle)
            } else {
                try? await NewsRepo.shared.removeFromFavorites(article: updatedArticle)
            }

            if let index = news.firstIndex(where: { $0.id == updatedArticle.id }) {
                news[index] = updatedArticle
                await MainActor.run {
                    let indexPath = IndexPath(row: index, section: 0)
                    if let cell = tableView.cellForRow(at: indexPath) as? NewsTableViewCell {
                        cell.configure(with: updatedArticle, delegate: self)
                    } else {
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell
        let newsArticle = news[indexPath.row]
        cell.configure(with: newsArticle, delegate: self)
        return cell
    }
    

    @IBOutlet private weak var searchField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    
    @IBAction func onSearchButtonTapped(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        Task {
            do {
                self.news = try await NewsRepo.shared.getNews(page: 1, search: nil)
                await MainActor.run { self.tableView.reloadData() }
            } catch {
                print("Помилка завантаження: \(error)")
            }
        }
    }

}

