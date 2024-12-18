//
// GoogleVisionAPI.swift
//
// This file provides functionality to interact with the Google Vision API to perform OCR (Optical Character Recognition) on images.
// It sends image data to the Google Vision API and processes the response to extract recognized text.
//

import Foundation

// A struct to interact with the Google Vision API for text detection
struct GoogleVisionAPI {
    // MARK: - Properties

    private static let apiKey = "AIzaSyA3LWq08ELpDyHZ80j4jIrH77Yd5Fe7ABM" // Google Vision API key
    private static let endpoint = "https://vision.googleapis.com/v1/images:annotate?key=" // API endpoint URL

    // MARK: - Public Methods

    /// Sends an image to the Google Vision API and retrieves recognized text.
    /// - Parameters:
    ///   - imageData: The raw image data (binary format) to be analyzed.
    ///   - completion: A closure that returns the recognized text as a `String`.
    static func analyzeImage(imageData: Data, completion: @escaping (String) -> Void) {
        // Step 1: Encode the image to Base64 format (required by Google Vision API)
        let base64Image = imageData.base64EncodedString()

        // Step 2: Construct the request payload
        let requestBody: [String: Any] = [
            "requests": [ // Contains all the requests for the API
                [
                    "image": ["content": base64Image], // Encoded image data
                    "features": [["type": "DOCUMENT_TEXT_DETECTION"]] // Feature: Text Detection
                ]
            ]
        ]

        // Step 3: Build the HTTP POST request
        guard let url = URL(string: endpoint + apiKey), // Combine endpoint and API key
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { // Serialize request body
            print("Failed to construct request.") // Error when building the request
            completion("") // Return an empty string in case of failure
            return
        }

        var request = URLRequest(url: url) // Initialize URLRequest
        request.httpMethod = "POST" // Use POST for sending the payload
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Specify JSON content type
        request.httpBody = jsonData // Attach serialized JSON as the request body

        // Step 4: Send the HTTP request using URLSession
        URLSession.shared.dataTask(with: request) { data, _, error in
            // Handle network or request errors
            if let error = error {
                print("Error calling Google Vision API: \(error.localizedDescription)")
                completion("") // Return empty result on failure
                return
            }

            // Log the raw API response for debugging purposes
            if let data = data {
                print("Raw API Response: \(String(data: data, encoding: .utf8) ?? "No response")")
            }

            // Step 5: Parse the API response
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responses = json["responses"] as? [[String: Any]] {
                
                // Option 1: Extract full text from "fullTextAnnotation"
                if let fullText = responses.first?["fullTextAnnotation"] as? [String: Any],
                   let text = fullText["text"] as? String {
                    completion(text) // Return the full extracted text
                }
                // Option 2: Extract first description from "textAnnotations" array as fallback
                else if let textAnnotations = responses.first?["textAnnotations"] as? [[String: Any]],
                        let firstAnnotation = textAnnotations.first,
                        let text = firstAnnotation["description"] as? String {
                    completion(text) // Return the first recognized text description
                }
                // If no text is found in the response
                else {
                    print("No text found in response.") // Log that no text was detected
                    completion("") // Return an empty result
                }
            } else {
                print("Failed to parse Google Vision API response.") // Log parsing failure
                completion("") // Return an empty result on failure
            }
        }.resume() // Start the network request
    }
}
