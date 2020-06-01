//
//  TranscriptPDF.swift
//  Transcript
//
//  Created by Tobi Kuyoro on 29/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import Foundation
import PDFKit

class TranscriptPDF {
    let title: String
    let text: String

    init(title: String, text: String) {
        self.title = title
        self.text = text
    }

    func createTranscript() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Transcript",
            kCGPDFContextAuthor: "tobikuyoro.com",
            kCGPDFContextTitle: title
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()

            let titleSize = addTitle(pageRect: pageRect)
            addBodyText(pageRect: pageRect, textTop: titleSize + 36.0)
        }

        return data
    }

    func addTitle(pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: titleFont]

        let attributedTitle = NSAttributedString(
            string: title,
            attributes: titleAttributes
        )

        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(
            x: (pageRect.width - titleStringSize.width) / 2.0,
            y: 36,
            width: titleStringSize.width,
            height: titleStringSize.height
        )

        attributedTitle.draw(in: titleStringRect)

        return titleStringRect.origin.y + titleStringRect.size.height
    }

    func addBodyText(pageRect: CGRect, textTop: CGFloat) {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 8

        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]

        let attributedText = NSAttributedString(
            string: text,
            attributes: textAttributes
        )

        let textRect = CGRect(
            x: 10,
            y: textTop,
            width: pageRect.width - 20,
            height: pageRect.height - textTop - pageRect.height / 5.0
        )

        attributedText.draw(in: textRect)
    }
}
