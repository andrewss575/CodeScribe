//
//  RecognizerHelper.swift
//  CodeScribe
//
//  Created by Andrew Saldana on 12/12/24.
//


import Vision
import PencilKit
import UIKit

// RecognizerHelper handles handwriting recognition using Vision framework.
struct RecognizerHelper {
    // Recognizes text from the given PKCanvasView and returns the result via a completion handler
    static func recognizeText(from canvasView: PKCanvasView, completion: @escaping (String) -> Void) {
        // Capture the current state of the canvas as an image
        let bounds = canvasView.bounds
        let scale = UIScreen.main.scale * 10  // Increase scale to improve image quality

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            // Render the canvas into the graphics context
            canvasView.layer.render(in: context)
        }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            // If rendering fails, print an error and exit
            UIGraphicsEndImageContext()
            print("Failed to get image from current context")
            completion("")
            return
        }
        UIGraphicsEndImageContext()

        // Convert UIImage to CGImage for Vision framework
        guard let cgImage = image.cgImage else {
            print("Failed to convert UIImage to CGImage")
            completion("")
            return
        }

        // Create a text recognition request
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                // Handle recognition errors
                print("Text recognition error: \(error.localizedDescription)")
                completion("")
                return
            }

            // Process the recognition results
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No text recognized")
                completion("")
                return
            }

            // Extract recognized text from observations
            let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            completion(recognizedText)
        }

        // Configure recognition parameters
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false  // Disable language correction for code recognition
        request.revision = VNRecognizeTextRequestRevision3  // Use the latest revision

        // Create an image request handler and perform the recognition
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                // Handle errors during request handling
                print("Failed to perform text recognition: \(error.localizedDescription)")
                completion("")
            }
        }
    }
}
