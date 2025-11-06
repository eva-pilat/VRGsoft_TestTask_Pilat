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
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
            
            NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
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
        guard let query = searchField.text, !query.isEmpty else { return }
        Task {
            do {
                let results = try await NewsRepo.shared.getNews(page: 1, search: query)
                self.news = results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Помилка: \(error)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Помилка", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshNews),
            name: .favoritesDidChange,
            object: nil
        )
        // Do any additional setup after loading the view.
    }
    
    @objc private func refreshNews() {
        Task {
            do {
                self.news = try await NewsRepo.shared.getNews(page: 1, search: nil)
                await MainActor.run { self.tableView.reloadData() }
            } catch {
                print("Помилка: \(error)")
            }
        }
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

