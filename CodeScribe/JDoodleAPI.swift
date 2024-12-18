//
//  JDoodleAPI.swift
//  CodeScribe
//
//  This file defines the JDoodleAPI class, which handles communication with the JDoodle Compiler API.
//  It sends code, language, and version information to the JDoodle API for execution
//  and returns the output or errors from the server.
//

import Foundation

// MARK: - JDoodleAPI Class

/// Handles communication with the JDoodle Compiler API for remote code execution.
class JDoodleAPI {
    // MARK: - Properties
    
    private let apiUrl = "https://api.jdoodle.com/v1/execute" // JDoodle API endpoint
    
    // JDoodle API credentials for authentication
    private let clientId = "12381fcf65ca6ab997c4eb5d65b1697e"
    private let clientSecret = "f7cf7c2a4ae4df538b1b162c20082bf094142664d4d30e4d2d18ed4879fe03e0"

    // MARK: - Public Methods

    /// Executes the provided code using the JDoodle Compiler API.
    /// - Parameters:
    ///   - script: The source code to execute.
    ///   - language: The programming language for the code (e.g., "python3", "java").
    ///   - versionIndex: The version index for the language (required by JDoodle).
    ///   - completion: A closure returning either the execution output (success) or an error (failure).
    func executeCode(script: String, language: String, versionIndex: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Step 1: Create the request payload
        let parameters: [String: Any] = [
            "clientId": clientId, // Authentication ID
            "clientSecret": clientSecret, // Authentication secret key
            "script": script, // The code to execute
            "language": language, // The programming language
            "versionIndex": versionIndex // The version of the language
        ]

        // Step 2: Convert parameters to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            completion(.failure(NSError(domain: "JDoodleAPI", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid request parameters" // Error when JSON serialization fails
            ])))
            return
        }

        // Step 3: Create the URL request
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "JDoodleAPI", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid API URL" // Error when API URL is invalid
            ])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Use POST method for the API call
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Specify JSON content type
        request.httpBody = jsonData // Attach the JSON payload

        // Step 4: Perform the network request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network-related errors
            if let error = error {
                completion(.failure(error)) // Return the error if the network request fails
                return
            }

            // Verify the HTTP response status
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "JDoodleAPI", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid response from server" // Error for bad HTTP responses
                ])))
                return
            }

            // Step 5: Parse the JSON response
            do {
                // Attempt to decode the response JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let output = json["output"] as? String { // Extract "output" field
                    completion(.success(output)) // Return the execution output
                } else {
                    completion(.failure(NSError(domain: "JDoodleAPI", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Unexpected response format" // Error when parsing fails
                    ])))
                }
            } catch {
                completion(.failure(error)) // Return any JSON parsing errors
            }
        }

        task.resume() // Start the network task
    }
}
