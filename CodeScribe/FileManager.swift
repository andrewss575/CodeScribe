//
//  FileManager.swift
//  CodeScribe
//
//  This file defines the file management system for the CodeScribe app.
//  It includes models for code files, methods for saving/loading data to disk,
//  and a SwiftUI view for managing files.
//

import Foundation
import PencilKit
import SwiftUI

// MARK: - CodeFile Model

/// Represents a single code file with a name, script content, and an optional drawing.
struct CodeFile: Identifiable, Codable {
    let id: UUID // Unique identifier for each file
    var name: String // Name of the file
    var canvasDrawing: Data? // Serialized PKDrawing data for canvas content
    var script: String // Code editor content
}

// MARK: - FileManagerModel Class

/// Manages the collection of `CodeFile` objects and persists them to disk.
class FileManagerModel: ObservableObject {
    @Published var files: [CodeFile] = [] // Published array of code files for use in SwiftUI views

    /// Creates a new file with a specified name.
    /// - Parameter name: The name of the new file.
    func createNewFile(name: String) {
        let newFile = CodeFile(id: UUID(), name: name, canvasDrawing: nil, script: "") // Initialize a new file
        files.append(newFile) // Append the new file to the collection
    }
    
    /// Deletes a file at the specified index set.
    /// - Parameter indexSet: The index set of the file to delete.
    func deleteFile(at indexSet: IndexSet) {
        files.remove(atOffsets: indexSet) // Remove the file from the array
    }
    
    /// Saves the current list of files to persistent storage using `UserDefaults`.
    func saveToDisk() {
        guard let encodedData = try? JSONEncoder().encode(files) else { return } // Encode files into JSON
        UserDefaults.standard.set(encodedData, forKey: "savedFiles") // Save the JSON to UserDefaults
    }
    
    /// Loads previously saved files from persistent storage.
    func loadFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: "savedFiles"), // Retrieve saved data
              let decodedFiles = try? JSONDecoder().decode([CodeFile].self, from: data) else { return }
        files = decodedFiles // Update the files array with loaded data
    }
}

// MARK: - FileManagerView

/// SwiftUI view for managing files: viewing, creating, and deleting files.
struct FileManagerView: View {
    @ObservedObject var fileManager = FileManagerModel() // Observes file manager for changes
    @State private var newFileName = "" // State variable to hold the name of a new file
    @State private var selectedFile: CodeFile? // State to track the currently selected file

    var body: some View {
        NavigationView { // Navigation view for file management
            VStack {
                // List of Files
                List {
                    ForEach(fileManager.files) { file in // Loop through all files
                        Button(action: {
                            selectedFile = file // Set the selected file when tapped
                        }) {
                            Text(file.name) // Display the file name
                        }
                    }
                    .onDelete(perform: fileManager.deleteFile) // Enable swipe-to-delete functionality
                }

                // Add New File Section
                HStack {
                    TextField("New File Name", text: $newFileName) // Input field for new file name
                        .textFieldStyle(RoundedBorderTextFieldStyle()) // Rounded border styling for the text field
                    
                    Button("Add") { // Button to add a new file
                        guard !newFileName.isEmpty else { return } // Ensure the name is not empty
                        fileManager.createNewFile(name: newFileName) // Create the new file
                        newFileName = "" // Clear the input field
                    }
                }
                .padding() // Add padding around the HStack
            }
            .navigationTitle("My Files") // Title for the navigation bar
            .toolbar {
                EditButton() // Provides an edit button for deleting files in the list
            }
        }
        .onAppear {
            fileManager.loadFromDisk() // Load files when the view appears
        }
        .onDisappear {
            fileManager.saveToDisk() // Save files when the view disappears
        }
    }
}
