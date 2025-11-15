//
//  CategiriesViewController.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 03.11.2025.
//

import UIKit

class CategiriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ArticleCellDelegate {
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
    
    private var tableView = UITableView()
    private var categoryControlButton = UIButton(type: .system)
    
    
    private var news: [Model.NewsArticle] = []
    private var selectedCategory: Model.NewsCategory? = nil
    private var currentPage: Int = 1
    private var isLoading = false
    
    func updateMenu(selected: String) {
        let actions = Model.NewsCategory.allCases.map { category in
            UIAction(title: category.rawValue, state: category.rawValue == selected ? .on : .off) { [weak self] _ in
                Task {
                    await self?.selectCategory(category)
                }
            }
        }
        categoryControlButton.menu = UIMenu(title: "Choose Category", children: actions)
    }
    
    func selectCategory(_ category: Model.NewsCategory) async {
        do {
            selectedCategory = category
            await MainActor.run {
                self.categoryControlButton.setTitle(category.rawValue, for: .normal)
                self.updateMenu(selected: category.rawValue)
            }
            news = try await NewsRepo.shared.getNewsByCategory(category: category, page: 1)
            await MainActor.run {
                self.tableView.reloadData()
            }
        } catch {
            print("error fetching category news: \(error)")
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "NewsCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: categoryControlButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCategoryControl() {
        view.addSubview(categoryControlButton)
        categoryControlButton.translatesAutoresizingMaskIntoConstraints = false
        categoryControlButton.showsMenuAsPrimaryAction = true
        
        categoryControlButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        
        updateMenu(selected: Model.NewsCategory.general.rawValue)
        categoryControlButton.setTitle(Model.NewsCategory.general.rawValue, for: .normal)
        
        NSLayoutConstraint.activate([
            categoryControlButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryControlButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryControlButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCategoryControl()
        setupTableView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        // Do any additional setup after loading the view.
    }
    
    @objc private func pullToRefresh() {
        Task {
            do {
                currentPage = 1
                let results = try await NewsRepo.shared.getNewsByCategory(category: self.selectedCategory, page: 1)
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
    
    private func loadMoreNews() {
        isLoading = true
        Task {
            do {
                currentPage += 1
                let newResults = try await NewsRepo.shared.getNewsByCategory(category: selectedCategory, page: currentPage)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            do {
                self.currentPage = 1
                self.news = try await NewsRepo.shared.getNewsByCategory(category: selectedCategory, page: 1)
                await MainActor.run {
                    self.tableView.reloadData()
                    if let selected = self.selectedCategory?.rawValue {
                        self.updateMenu(selected: selected)
                        self.categoryControlButton.setTitle(selected, for: .normal)
                    }
                }
            } catch {
                print("Помилка завантаження: \(error)")
            }
        }
    }

}
