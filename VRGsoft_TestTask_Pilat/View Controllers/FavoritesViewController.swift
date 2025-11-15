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
                if !updated.isFavorite {
                    favorites.remove(at: index)
                    await MainActor.run {
                        let indexPath = IndexPath(row: index, section: 0)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                } else {
                    favorites[index] = updated
                    await MainActor.run {
                        let indexPath = IndexPath(row: index, section: 0)
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
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
    

    private var tableView = UITableView()
    private var favorites: [Model.NewsArticle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "NewsCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
                print("Помилка pull-to-refresh")
                await MainActor.run {
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }

}
