//
//  SciptDetailViewController.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 26/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class SciptDetailViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet var backButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var transcriptTextView: UITextView!

    // MARK: - Properties

    let transcript: TranscriptModel

    // MARK: - Initializers

    init?(coder: NSCoder, transcript: TranscriptModel) {
        self.transcript = transcript
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonTapped(_ sender: Any) {
    }

    @IBAction func editButtonTapped(_ sender: Any) {
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
