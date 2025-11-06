//
//  ViewController.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 03.11.2025.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! NewsTableViewCell
        //let newsArticle = news[indexPath.row]
        //cell.configure(with: newsArticle, delegate: self)
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
        // Do any additional setup after loading the view.
    }


}

