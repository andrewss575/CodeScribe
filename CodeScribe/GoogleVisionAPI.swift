import Foundation

struct GoogleVisionAPI {
    private static let apiKey = "AIzaSyA3LWq08ELpDyHZ80j4jIrH77Yd5Fe7ABM"
    private static let endpoint = "https://vision.googleapis.com/v1/images:annotate?key="

    static func analyzeImage(imageData: Data, completion: @escaping (String) -> Void) {
        // Encode the image to Base64
        let base64Image = imageData.base64EncodedString()

        // Construct the request payload
        let requestBody: [String: Any] = [
            "requests": [
                [
                    "image": ["content": base64Image],
                    "features": [["type": "DOCUMENT_TEXT_DETECTION"]]
                ]
            ]
        ]

        // Build the HTTP request
        guard let url = URL(string: endpoint + apiKey),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Failed to construct request.")
            completion("")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Send the request
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error calling Google Vision API: \(error.localizedDescription)")
                completion("")
                return
            }

            if let data = data {
                print("Raw API Response: \(String(data: data, encoding: .utf8) ?? "No response")")
            }
            
            // Parse the response
            if let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let responses = json["responses"] as? [[String: Any]] {
                     
                     // First, check for fullTextAnnotation
                     if let fullText = responses.first?["fullTextAnnotation"] as? [String: Any],
                        let text = fullText["text"] as? String {
                         completion(text) // Return the extracted full text
                     }
                     // Fallback: Check for textAnnotations array
                     else if let textAnnotations = responses.first?["textAnnotations"] as? [[String: Any]],
                             let firstAnnotation = textAnnotations.first,
                             let text = firstAnnotation["description"] as? String {
                         completion(text) // Return the description from textAnnotations
                     } else {
                         print("No text found in response.")
                         completion("")
                     }
                 } else {
                     print("Failed to parse Google Vision API response.")
                     completion("")
                 }
        }.resume()
    }
}
