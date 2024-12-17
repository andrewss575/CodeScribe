import Foundation
import PencilKit

struct CodeFile: Identifiable, Codable {
    let id: UUID // Unique identifier for each file
    var name: String // Name of the file
    var canvasDrawing: Data? // PKDrawing serialized to data
    var script: String // Code editor content
}

class FileManagerModel: ObservableObject {
    @Published var files: [CodeFile] = []
    
    // Create a new file
    func createNewFile(name: String) {
        let newFile = CodeFile(id: UUID(), name: name, canvasDrawing: nil, script: "")
        files.append(newFile)
    }
    
    // Delete a file
    func deleteFile(at indexSet: IndexSet) {
        files.remove(atOffsets: indexSet)
    }
    
    // Save files to disk
    func saveToDisk() {
        guard let encodedData = try? JSONEncoder().encode(files) else { return }
        UserDefaults.standard.set(encodedData, forKey: "savedFiles")
    }
    
    // Load files from disk
    func loadFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: "savedFiles"),
              let decodedFiles = try? JSONDecoder().decode([CodeFile].self, from: data) else { return }
        files = decodedFiles
    }
}

import SwiftUI

struct FileManagerView: View {
    @ObservedObject var fileManager = FileManagerModel()
    @State private var newFileName = ""
    @State private var selectedFile: CodeFile?

    var body: some View {
        NavigationView {
            VStack {
                // List of Files
                List {
                    ForEach(fileManager.files) { file in
                        Button(action: {
                            selectedFile = file
                        }) {
                            Text(file.name)
                        }
                    }
                    .onDelete(perform: fileManager.deleteFile)
                }

                // Add New File
                HStack {
                    TextField("New File Name", text: $newFileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        guard !newFileName.isEmpty else { return }
                        fileManager.createNewFile(name: newFileName)
                        newFileName = ""
                    }
                }
                .padding()
            }
            .navigationTitle("My Files")
            .toolbar {
                EditButton()
            }
        }
        .onAppear {
            fileManager.loadFromDisk()
        }
        .onDisappear {
            fileManager.saveToDisk()
        }
    }
}
