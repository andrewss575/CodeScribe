//
//  RecognizerHelper.swift
//  CodeScribe
//
//  Created by Andrew Saldana on 12/12/24.
//


import Vision
import PencilKit
import UIKit

struct RecognizerHelper {
    // Function to automatically indent Python code
        static func autoIndentCode(_ rawText: String) -> String {
            let keywords = ["if", "for", "while", "def", "class", "try", "except", "with", "else:", "elif", "finally:"]
            var indentedText = ""
            var indentationLevel = 0
            var shouldIndentNextLine = false

            let lines = rawText.split(separator: "\n")
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                
                // If the line is empty, add a new line and continue
                if trimmedLine.isEmpty {
                    indentedText += "\n"
                    continue
                }

                // Add current indentation
                indentedText += String(repeating: "    ", count: indentationLevel) + trimmedLine + "\n"

                // If we just indented due to a keyword, reset the flag
                if shouldIndentNextLine {
                    shouldIndentNextLine = false
                    continue
                }

                // Check if this line ends with ':' or starts with a keyword -> Indent next line
                if keywords.contains(where: { trimmedLine.hasPrefix($0) }) || trimmedLine.hasSuffix(":") {
                    indentationLevel += 1
                    shouldIndentNextLine = true
                }

                // If the current line starts with dedent triggers, reduce the indentation
                if trimmedLine.hasPrefix("return") || trimmedLine.hasPrefix("pass") || trimmedLine.hasPrefix("break") {
                    indentationLevel = max(indentationLevel - 1, 0)
                }
            }
            return indentedText
        }
    // Recognize text: Choose between Apple's Vision and Google Vision API
    static func recognizeText(from canvasView: PKCanvasView, useGoogleVision: Bool, completion: @escaping (String) -> Void) {
        // 1. Capture the canvas as an image
        let bounds = canvasView.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            print("Failed to get image data")
            completion("")
            return
        }

        // 2. Choose the OCR engine
        if useGoogleVision {
            // Use Google Vision API
            GoogleVisionAPI.analyzeImage(imageData: imageData, completion: completion)
        } else {
            // Use Apple's Vision framework
            recognizeTextWithVision(imageData: imageData, completion: completion)
        }
    }

    // Apple's Vision Framework for text recognition
    private static func recognizeTextWithVision(imageData: Data, completion: @escaping (String) -> Void) {
        guard let cgImage = UIImage(data: imageData)?.cgImage else {
            print("Failed to create CGImage")
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion("")
                return
            }

            // Extract recognized text
            let recognizedText = (request.results as? [VNRecognizedTextObservation])?
                .compactMap { $0.topCandidates(1).first?.string } // Get the best candidate for each observation
                .joined(separator: "\n") ?? "" // Join results with newlines
            completion(recognizedText)
        }
        request.recognitionLevel = .accurate // Use high accuracy

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error.localizedDescription)")
            completion("")
        }
    }
}
