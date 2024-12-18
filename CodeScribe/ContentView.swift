//
// ContentView.swift
// CodeScribe
//
// This file defines the primary user interface for the CodeScribe application.
// It includes functionalities for managing files, editing code, drawing on a canvas, and executing code in various languages.
//

// Import necessary modules
import SwiftUI // Provides tools for building the user interface
import PencilKit // Provides tools for drawing and handwriting

// Main view of the application
struct ContentView: View {
    @StateObject private var fileManager = FileManagerModel() // Observes and manages the file operations
    @State private var isAddingFile = false // Tracks whether the "Add File" alert is displayed
    @State private var newFileName = "" // Stores the name of the new file being created

    var body: some View {
        NavigationView { // Creates a navigation-based user interface
            VStack { // Arranges elements vertically
                // File Management Section (Header)
                HStack { // Arranges elements horizontally
                    Text("Files") // Displays the title "Files"
                        .font(.largeTitle) // Sets the font size to large
                        .fontWeight(.bold) // Makes the font bold

                    Spacer() // Adds flexible spacing to push content to edges

                    Button(action: { // Button to add a new file
                        isAddingFile.toggle() // Toggles the display of the "New File" alert
                    }) {
                        HStack { // Groups button content
                            Image(systemName: "plus") // Displays a "+" icon
                            Text("New File") // Displays the button label
                        }
                        .padding() // Adds padding around the button
                        .background(Color.blue) // Sets the background color to blue
                        .foregroundColor(.white) // Sets the text color to white
                        .cornerRadius(10) // Rounds the corners of the button
                    }
                }
                .padding() // Adds padding around the header section

                // List of Files Section
                List { // Displays a list of files
                    ForEach(fileManager.files) { file in // Iterates over the list of files
                        NavigationLink(destination: FileEditorView(file: file, fileManager: fileManager)) {
                            // Navigates to the FileEditorView when a file is selected
                            Text(file.name) // Displays the file name
                                .font(.headline) // Sets the font size to headline
                        }
                    }
                    .onDelete(perform: fileManager.deleteFile) // Enables swipe-to-delete functionality
                }
                .listStyle(PlainListStyle()) // Applies a plain style to the list

                .alert("New File", isPresented: $isAddingFile, actions: { // Displays an alert to create a new file
                    TextField("Enter file name", text: $newFileName) // Input for the new file name
                    Button("Create") { // Creates the new file
                        guard !newFileName.isEmpty else { return } // Ensures the file name is not empty
                        fileManager.createNewFile(name: newFileName) // Calls the file manager to create a new file
                        newFileName = "" // Resets the file name field
                    }
                    Button("Cancel", role: .cancel, action: {}) // Cancels the alert
                })
            }
            .navigationTitle("CodeScribe") // Sets the navigation title
            .onAppear { // Triggered when the view appears
                fileManager.loadFromDisk() // Loads files from disk
            }
            .onDisappear { // Triggered when the view disappears
                fileManager.saveToDisk() // Saves files to disk
            }
        }
    }
}

// This view provides an interface for editing a file's content, including a drawing canvas,
// a code editor, and functionalities like code execution and language selection.

struct FileEditorView: View {
    @State var file: CodeFile // Represents the file being edited
    @State private var canvasView = PKCanvasView() // Canvas for drawing content
    @ObservedObject var fileManager: FileManagerModel // Manages file operations
    @State private var penColor = UIColor.black // Default pen color for drawing
    @State private var isEraserActive = false // Tracks whether the eraser is active
    @State private var penSize: CGFloat = 2.0 // Default pen size for drawing
    @State private var script = "# Python 3 Template\n# Your code starts here" // Default Python script template
    @State private var output = "" // Stores the output of executed code
    @State private var isExecuting = false // Tracks whether the code execution is in progress
    @State private var selectedLanguage = "Python 3" // Default programming language
    @State private var useGoogleVision = false // Toggle to switch between APIs for handwriting recognition
    
    // JDoodle API instance for executing code
    private let jdoodleAPI = JDoodleAPI()
    
    // Supported programming languages
    private let languages = ["Python 3", "Java", "C", "C++"]
    
    // Mapping of languages to JDoodle API parameters
    private let languageMap: [String: (language: String, versionIndex: String)] = [
        "Python 3": ("python3", "3"),
        "Java": ("java", "4"),
        "C": ("c", "5"),
        "C++": ("cpp17", "0"),
    ]
    
    // Available pen colors for drawing
    private let colors: [UIColor] = [.black, .red, .blue, .green, .orange, .purple]
    
    // Available pen sizes for drawing
    private let sizes: [CGFloat] = [1.0, 2.0, 3.0, 5.0, 8.0]
    
    // Templates for each programming language
    private let languageTemplates: [String: String] = [
        "Python 3": """
        # Python 3 Template
        # Your code starts here
        """,
        "C++": """
        #include <iostream>
        using namespace std;
        
        int main() {
            // Your code starts here
            return 0;
        }
        """,
        "Java": """
        public class Main {
            public static void main(String[] args) {
                // Your code starts here
            }
        }
        """,
        "C": """
        #include <stdio.h>
        
        int main() {
            // Your code starts here
            return 0;
        }
        """
    ]
    
    // Custom initializer for FileEditorView
    init(file: CodeFile, fileManager: FileManagerModel) {
        self.file = file // Assign the file being edited
        self.fileManager = fileManager // Assign the file manager
        
        // Default script is set to the Python template if the file's script is empty
        let initialScript = file.script.isEmpty ? """
        # Python 3 Template
        # Your code starts here
        """ : file.script
        
        self._script = State(initialValue: initialScript) // Initialize the script state
        
        // Initialize the canvas view with a drawing from the file, if available
        if let data = file.canvasDrawing {
            self._canvasView = State(initialValue: {
                let view = PKCanvasView()
                view.drawing = try! PKDrawing(data: data) // Load the drawing from file data
                return view
            }())
        }
    }
    
    var body: some View {
        ScrollView { // Enables scrolling for the entire content
            HStack(alignment: .top, spacing: 20) { // Main horizontal layout with spacing between columns
                // Left Column: Canvas and Drawing Tools
                VStack(spacing: 30) { // Arranges components vertically with spacing
                    // Section Title: Canvas
                    Text("Canvas")
                        .font(.largeTitle) // Large title font size
                        .fontWeight(.bold) // Makes the title bold
                    
                    // Canvas View with Zoom functionality
                    ZStack {
                        ZoomableCanvasView(canvasView: $canvasView, penColor: $penColor, penSize: $penSize)
                    }
                    .frame(height: 750) // Sets a fixed height for the canvas
                    .border(Color.gray, width: 1) // Adds a gray border around the canvas
                    
                    // Pen Customization Toolbar
                    HStack(spacing: 10) { // Horizontal layout for color and size pickers
                        // Color Picker Buttons
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                penColor = color // Updates the pen color
                            }) {
                                Circle()
                                    .fill(Color(color)) // Displays color options
                                    .frame(width: 45, height: 45) // Button size
                                    .overlay(
                                        Circle()
                                            .stroke(penColor == color ? Color.white : Color.clear, lineWidth: 2)
                                    ) // Highlights the selected color
                            }
                        }
                        
                        // Pen Size Picker Buttons
                        ForEach(sizes, id: \.self) { size in
                            Button(action: {
                                penSize = size // Updates the pen size
                            }) {
                                Text("\(Int(size))") // Displays size as text
                                    .padding(8)
                                    .background(penSize == size ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(5) // Highlights the selected size
                            }
                        }
                    }
                    
                    // Toolbar for Drawing Actions
                    HStack(spacing: 10) { // Horizontal layout for actions
                        // Clear Canvas Button
                        Button(action: clearCanvas) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear")
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        // Toggle Pen/Eraser Tool
                        Button(action: toggleTool) {
                            HStack {
                                Image(systemName: isEraserActive ? "pencil" : "eraser")
                                Text(isEraserActive ? "Pen" : "Eraser")
                            }
                            .padding()
                            .background(isEraserActive ? Color.green : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        // Recognize Handwriting Button
                        Button(action: {
                            RecognizerHelper.recognizeText(from: canvasView, useGoogleVision: useGoogleVision) { recognizedText in
                                DispatchQueue.main.async {
                                    let formattedText = RecognizerHelper.autoIndentCode(recognizedText)
                                    
                                    // Inserts recognized text into the code editor
                                    if let range = script.range(of: "Your code starts here") {
                                        let insertPosition = range.upperBound
                                        script.insert(contentsOf: "\n\(formattedText)", at: insertPosition)
                                    } else {
                                        script += "\n\(formattedText)"
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "text.viewfinder")
                                Text("Codeify")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        // Toggle to Use Google Vision API
                        Toggle("Use Google Vision", isOn: $useGoogleVision)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                
                Divider() // Visual separator between the columns
                
                // Right Column: Code Editor and Execution
                VStack(alignment: .leading, spacing: 30) { // Arranges components vertically
                    // Section Title: Code Editor
                    Text("Code Editor:")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Language Selection Picker
                    VStack(alignment: .leading) {
                        Text("Select Language:")
                            .font(.subheadline)
                            .padding(.horizontal)
                        
                        Picker("Language", selection: $selectedLanguage) {
                            ForEach(languages, id: \.self) { language in
                                Text(language) // Displays language options
                            }
                        }
                        .onChange(of: selectedLanguage) { newLanguage in
                            // Updates script template when language changes
                            script = languageTemplates[newLanguage] ?? ""
                        }
                        .pickerStyle(MenuPickerStyle())
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding()
                    }
                    
                    // Code Editor with Syntax Highlighting
                    SyntaxHighlightingTextEditor(text: $script, language: selectedLanguage)
                        .frame(height: 300) // Fixed height for the editor
                        .border(Color.gray, width: 1)
                        .padding(.horizontal)
                    
                    // Action Buttons: Execute Code and Clear Editor
                    HStack {
                        // Execute Code Button
                        Button(action: executeCode) {
                            if isExecuting {
                                ProgressView() // Shows a progress indicator while executing
                                    .padding()
                            } else {
                                Text("Run Code")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(isExecuting) // Disables the button while execution is in progress
                        .padding(.horizontal)
                        
                        // Clear Code Editor Button
                        Button(action: clearCodeEditor) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear Code Editor")
                            }
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Output Section
                    VStack(alignment: .leading) { // Displays the output of executed code
                        Text("Output:")
                            .font(.headline)
                        ScrollView { // Scrollable area for output
                            Text(output)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                        }
                        .frame(maxHeight: 150) // Restricts the output height
                    }
                }
                .frame(maxWidth: .infinity) // Ensures the right column uses available space
            }
            .padding() // Adds padding to the entire content
        }
        .background(Color(UIColor.systemGray5)) // Sets a light gray background
        .edgesIgnoringSafeArea(.all) // Extends the background to screen edges
    }
    
    // Function to clear the canvas
    func clearCanvas() {
        canvasView.drawing = PKDrawing() // Resets the canvas to an empty drawing
        // script = languageTemplates[selectedLanguage] ?? "" // (Optional) Reset the script to the template
    }
    
    // Function to clear the code editor
    func clearCodeEditor() {
        script = languageTemplates[selectedLanguage] ?? "" // Resets the code editor to the selected language's template
    }
    
    // Function to toggle between the pen and eraser tools
    func toggleTool() {
        if isEraserActive {
            // Switch to pen tool with the current color and size
            canvasView.tool = PKInkingTool(.pen, color: penColor, width: penSize)
        } else {
            // Switch to eraser tool
            canvasView.tool = PKEraserTool(.vector)
        }
        isEraserActive.toggle() // Update the state to reflect the current tool
    }
    
    // Function to recognize handwriting from the canvas and update the script
    func recognizeHandwriting() {
        RecognizerHelper.recognizeText(from: canvasView, useGoogleVision: useGoogleVision) { recognizedText in
            DispatchQueue.main.async {
                // Locate the placeholder in the script to insert the recognized text
                if let insertionPoint = script.range(of: "Your code starts here") {
                    script.replaceSubrange(insertionPoint, with: "Your code starts here\n\(recognizedText)")
                } else {
                    // If the placeholder is not found, append the recognized text at the end
                    script += "\n" + recognizedText
                }
            }
        }
    }
    
    // Function to execute the code in the editor
    func executeCode() {
        isExecuting = true // Set executing state to true
        output = "Executing..." // Display a message indicating execution has started
        
        // Validate that the selected language is supported
        guard let languageInfo = languageMap[selectedLanguage] else {
            output = "Error: Unsupported language selected."
            isExecuting = false
            return
        }
        
        // Call the JDoodle API to execute the code
        jdoodleAPI.executeCode(script: script, language: languageInfo.language, versionIndex: languageInfo.versionIndex) { result in
            DispatchQueue.main.async {
                self.isExecuting = false // Reset the executing state
                switch result {
                case .success(let apiOutput):
                    self.output = apiOutput // Display the execution output
                case .failure(let error):
                    self.output = "Error: \(error.localizedDescription)" // Display the error message
                }
            }
            
            // Function to save changes to the file
            func saveFileChanges() {
                // Find the file index and update its content
                guard let index = fileManager.files.firstIndex(where: { $0.id == file.id }) else { return }
                fileManager.files[index].script = script // Save the current script
                fileManager.files[index].canvasDrawing = canvasView.drawing.dataRepresentation() // Save the current canvas state
                fileManager.saveToDisk() // Persist changes to disk
            }
        }
    }
}
