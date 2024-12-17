//
//  JDoodleAPI.swift
//  CodeScribe
//
//  Created by Andrew Saldana on 11/12/24.
//
import Foundation

// JDoodleAPI handles communication with the JDoodle Compiler API.
class JDoodleAPI {
    // Define API credentials and endpoint
    private let apiUrl = "https://api.jdoodle.com/v1/execute"
    private let clientId = "12381fcf65ca6ab997c4eb5d65b1697e"  
    private let clientSecret = "f7cf7c2a4ae4df538b1b162c20082bf094142664d4d30e4d2d18ed4879fe03e0"

    // Function to execute code on JDoodle
    func executeCode(script: String, language: String, versionIndex: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Create the request payload
        let parameters: [String: Any] = [
            "clientId": clientId,
            "clientSecret": clientSecret,
            "script": script,
            "language": language,
            "versionIndex": versionIndex
        ]

        // Convert parameters to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            completion(.failure(NSError(domain: "JDoodleAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request parameters"])))
            return
        }

        // Create the URL request
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "JDoodleAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Perform the network request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                completion(.failure(error))
                return
            }

            // Handle invalid responses
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "JDoodleAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }

            // Parse the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let output = json["output"] as? String {
                    completion(.success(output))
                } else {
                    completion(.failure(NSError(domain: "JDoodleAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
