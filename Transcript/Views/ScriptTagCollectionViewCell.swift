//
//  ScriptTagCollectionViewCell.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 26/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class ScriptTagCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    var categoryImage: UIImageView!
    var categoryLabel: UILabel!
    var scriptCountLabel: UILabel!

    var count = 0

    var transcripts: [TranscriptModel]? {
        didSet {
            updateViews()
        }
    }

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
        guard
            let category = category,
            let transcripts = transcripts else { return }

        categoryImage.image = UIImage(named: category.rawValue.lowercased())
        categoryLabel.text = category.rawValue.capitalized
        scriptCountLabel.isHidden = true

        for transcript in transcripts {
            if transcript.category == category.rawValue {
                count += 1
                scriptCountLabel.text = "\(count) TRANSCRIPTS"
                scriptCountLabel.isHidden = false
            }
        }
    }

    private func showCountLabel(_ count: inout Int, for category: TranscriptCategory) {
        count += 1
        scriptCountLabel.text = "\(count) TRANSCRIPTS"
        scriptCountLabel.isHidden = false
    }

    private func setUpSubviews() {
        layer.cornerRadius = 7
        clipsToBounds = true

        categoryImage = UIImageView()
        categoryImage.contentMode = .scaleAspectFill
        categoryImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoryImage)

        NSLayoutConstraint.activate([
            categoryImage.topAnchor.constraint(equalTo: topAnchor),
            categoryImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            categoryImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            categoryImage.widthAnchor.constraint(equalTo: widthAnchor)
        ])

        let darkView = UIView()
        darkView.backgroundColor = .black
        darkView.alpha = 0.75
        darkView.translatesAutoresizingMaskIntoConstraints = false
        categoryImage.addSubview(darkView)

        NSLayoutConstraint.activate([
            darkView.topAnchor.constraint(equalTo: categoryImage.topAnchor),
            darkView.leadingAnchor.constraint(equalTo: categoryImage.leadingAnchor),
            darkView.bottomAnchor.constraint(equalTo: categoryImage.bottomAnchor),
            darkView.widthAnchor.constraint(equalTo: categoryImage.widthAnchor)
        ])

        categoryLabel = UILabel()
        categoryLabel.textAlignment = .center
        categoryLabel.textColor = .white
        categoryLabel.alpha = 0.9
        categoryLabel.font = UIFont(name: "Play-Regular", size: 20)
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

        scriptCountLabel = UILabel()
        scriptCountLabel.textAlignment = .center
        scriptCountLabel.textColor = .white
        scriptCountLabel.alpha = 0.9
        scriptCountLabel.font = .systemFont(ofSize: 11, weight: .regular)
        scriptCountLabel.translatesAutoresizingMaskIntoConstraints = false
        darkView.addSubview(scriptCountLabel)

        NSLayoutConstraint.activate([
            scriptCountLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            scriptCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
