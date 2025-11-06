//
//  NewsTableViewCell.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 05.11.2025.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet private weak var articleTitle: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet weak var articleText: UITextView!
    @IBOutlet weak var articleImage: UIImageView!
    
    @IBAction func onSaveButtonTapped(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
