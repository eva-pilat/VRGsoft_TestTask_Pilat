//
//  ViewController.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 03.11.2025.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ArticleCellDelegate {
    
    private var searchField = UITextField()
    private var searchButton = UIButton()
    private var tableView = UITableView()
    
    private var news: [Model.NewsArticle] = []
    private var currentPage: Int = 1
    private var currentSearch: String? = nil
    private var isLoading = false
    
    private func setupSearch(){
        view.addSubview(searchField)
        view.addSubview(searchButton)
        
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.addTarget(self, action: #selector(onSearchButtonTapped(_:)), for: .touchUpInside)
        
        searchField.placeholder = "Search"
        searchField.borderStyle = .roundedRect
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -8),
            searchField.heightAnchor.constraint(equalToConstant: 30),
            
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchButton.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 44),
            searchButton.heightAnchor.constraint(equalToConstant: 44)
        ])
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
            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == news.count - 1 && !isLoading {
            loadMoreNews()
        }
    }
    
    @objc func onSearchButtonTapped(_ sender: Any) {
        guard let query = searchField.text, !query.isEmpty else { return }
        Task {
            do {
                currentSearch = query
                currentPage = 1
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        setupSearch()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    @objc private func pullToRefresh() {
        Task {
            do {
                currentPage = 1
                let results = try await NewsRepo.shared.getNews(page: currentPage, search: currentSearch)
                self.news = results
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            do {
                self.currentPage = 1
                self.news = try await NewsRepo.shared.getNews(page: 1, search: nil)
                await MainActor.run { self.tableView.reloadData() }
                
            } catch {
                print("Помилка завантаження: \(error)")
            }
                
        }
    }
    
    private func loadMoreNews() {
        isLoading = true
        Task {
            do {
                currentPage += 1
                let newResults = try await NewsRepo.shared.getNews(page: currentPage, search: currentSearch)
                if !newResults.isEmpty {
                    let startIndex = self.news.count
                    self.news += newResults
                    await MainActor.run {
                        let indexPaths = (startIndex..<self.news.count).map { IndexPath(row: $0, section: 0) }
                        self.tableView.insertRows(at: indexPaths, with: .automatic)
                    }
                }
            } catch {
                print("Помилка завантаження наступної сторінки")
                currentPage -= 1
            }
            isLoading = false
        }
    }

}

#if DEBUG
import SwiftUI

struct MyViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewController().showPreview()
    }
}

extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    
    func showPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif
