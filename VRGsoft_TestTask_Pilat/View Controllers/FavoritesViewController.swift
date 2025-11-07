//
//  FavoritesViewController.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 03.11.2025.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ArticleCellDelegate {
    
    func didToggleFavorite(article: Model.NewsArticle) {
        Task {
            var updated = article
            updated.isFavorite.toggle()
                    
            if updated.isFavorite {
                try? await NewsRepo.shared.addToFavorites(article: updated)
            } else {
                try? await NewsRepo.shared.removeFromFavorites(article: updated)
            }
            
            if let index = favorites.firstIndex(where: { $0.id == updated.id }) {
                favorites[index] = updated
                await MainActor.run {
                    let indexPath = IndexPath(row: index, section: 0)
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
                    
            NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell
        let article = favorites[indexPath.row]
        cell.configure(with: article, delegate: self)
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    private var favorites: [Model.NewsArticle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(loadFavorites),
//                                               name: .favoritesDidChange,
//                                               object: nil)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    @objc private func loadFavorites() {
        Task {
            do {
                self.favorites = try await NewsRepo.shared.getFavorites()
                await MainActor.run {
                    self.tableView.reloadData()
                }
            } catch {
                print("Помилка завантаження улюблених: \(error)")
            }
        }
    }
    
    @objc private func pullToRefresh() {
        Task {
            do {
                let results = try await NewsRepo.shared.getFavorites()
                self.favorites = results
                await MainActor.run {
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            } catch {
                print("Помилка pull-to-refresh: (error)")
                await MainActor.run {
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
