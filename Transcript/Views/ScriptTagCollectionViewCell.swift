//
//  ScriptTagCollectionViewCell.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 26/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class ScriptTagCollectionViewCell: UICollectionViewCell {

    @IBOutlet var categoryImage: UIImageView!

    var categoryLabel: UILabel!

    var category: TranscriptCategory? {
        didSet {
            updateViews()
        }
    }

    // MARK: - Cell Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }

    // MARK: - View Methods

    private func updateViews() {
        guard let category = category else { return }
        categoryImage.image = UIImage(named: category.rawValue)
        categoryLabel.text = category.rawValue.capitalized
    }

    private func setUpSubviews() {
        let darkView = UIView()
        darkView.backgroundColor = .black
        darkView.alpha = 0.7
        darkView.translatesAutoresizingMaskIntoConstraints = false
        categoryImage.addSubview(darkView)

        NSLayoutConstraint.activate([
            darkView.topAnchor.constraint(equalTo: categoryImage.topAnchor),
            darkView.leadingAnchor.constraint(equalTo: categoryImage.leadingAnchor),
            darkView.leadingAnchor.constraint(equalTo: categoryImage.trailingAnchor),
            darkView.bottomAnchor.constraint(equalTo: categoryImage.bottomAnchor)
        ])

        categoryLabel = UILabel()
        categoryLabel.textAlignment = .center
        categoryLabel.font = UIFont(name: "Play-Bold", size: 20)
        categoryLabel.textColor = .white
        categoryLabel.alpha = 0.9
        categoryLabel.adjustsFontSizeToFitWidth = true
        categoryLabel.minimumScaleFactor = 0.5
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        darkView.addSubview(categoryLabel)

        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: darkView.leadingAnchor, constant: 4),
            categoryLabel.trailingAnchor.constraint(equalTo: darkView.trailingAnchor, constant: -4),
            categoryLabel.centerXAnchor.constraint(equalTo: darkView.centerXAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: darkView.centerYAnchor)
        ])
    }
}
