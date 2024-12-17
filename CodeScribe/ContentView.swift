import SwiftUI
import PencilKit

struct ContentView: View {
    @StateObject private var fileManager = FileManagerModel()
    @State private var isAddingFile = false
    @State private var newFileName = "" // For creating a new file

    var body: some View {
        NavigationView {
            VStack {
                // File Management Section
                HStack {
                    Text("Files")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: {
                        isAddingFile.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New File")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()

                // List of Files
                List {
                    ForEach(fileManager.files) { file in
                        NavigationLink(destination: FileEditorView(file: file, fileManager: fileManager)) {
                            Text(file.name)
                                .font(.headline)
                        }
                    }
                    .onDelete(perform: fileManager.deleteFile)
                }
                .listStyle(PlainListStyle())

                .alert("New File", isPresented: $isAddingFile, actions: {
                    TextField("Enter file name", text: $newFileName)
                    Button("Create") {
                        guard !newFileName.isEmpty else { return }
                        fileManager.createNewFile(name: newFileName)
                        newFileName = ""
                    }
                    Button("Cancel", role: .cancel, action: {})
                })
            }
            .navigationTitle("CodeScribe")
            .onAppear {
                fileManager.loadFromDisk()
            }
            .onDisappear {
                fileManager.saveToDisk()
            }
        }
    }
}

struct FileEditorView: View {
    @State var file: CodeFile
    @State private var canvasView = PKCanvasView()
    @ObservedObject var fileManager: FileManagerModel
    @State private var penColor = UIColor.black
    @State private var isEraserActive = false
    @State private var penSize: CGFloat = 2.0
    @State private var script = "#Example \nprint('Hello, World!')" // Default Python code
    @State private var output = ""
    @State private var isExecuting = false
    @State private var selectedLanguage = "Python 3"

    private let jdoodleAPI = JDoodleAPI()
    private let languages = ["Python 3", "Java", "C", "C++", "JavaScript"]
    private let languageMap: [String: (language: String, versionIndex: String)] = [
        "Python 3": ("python3", "3"),
        "Java": ("java", "4"),
        "C": ("c", "5"),
        "C++": ("cpp17", "0"),
        "JavaScript": ("nodejs", "4")
    ]
    private let colors: [UIColor] = [.black, .red, .blue, .green, .orange, .purple]
    private let sizes: [CGFloat] = [1.0, 2.0, 3.0, 5.0, 8.0]
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
        """,
        "JavaScript": """
        // JavaScript Template
        console.log("Hello, World!");
        """
    ]

    
    init(file: CodeFile, fileManager: FileManagerModel) {
        self.file = file
        self.fileManager = fileManager
        self._script = State(initialValue: file.script)

        if let data = file.canvasDrawing {
            self._canvasView = State(initialValue: {
                let view = PKCanvasView()
                view.drawing = try! PKDrawing(data: data)
                return view
            }())
        }
    }

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 20) {
                // Left Column: Canvas and Tools
                VStack(spacing: 30) {
                    Text("Canvas")
                        .font(.largeTitle) // Change to a larger font, e.g., largeTitle
                        .fontWeight(.bold) // Optionally make it bold
                        .font(.headline)

                    // Zoomable Canvas
                    ZStack {
                        ZoomableCanvasView(canvasView: $canvasView, penColor: $penColor, penSize: $penSize)
                    }
                    .frame(height: 750)
                    .border(Color.gray, width: 1)

                    // Pen Customization Toolbar
                    HStack(spacing: 10) {
                        // Color Picker
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                penColor = color
                            }) {
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 45, height: 45)
                                    .overlay(Circle().stroke(penColor == color ? Color.white : Color.clear, lineWidth: 2))
                            }
                        }

                        // Size Picker
                        ForEach(sizes, id: \.self) { size in
                            Button(action: {
                                penSize = size
                            }) {
                                Text("\(Int(size))")
                                    .padding(8)
                                    .background(penSize == size ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                    }

                    // Toolbar for Drawing Actions
                    HStack(spacing: 10) {
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

                        Button(action: recognizeHandwriting) {
                            HStack {
                                Image(systemName: "text.viewfinder")
                                Text("Codeify")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }

                Divider()

                // Right Column: Code Editor and Execution
                VStack(alignment: .leading, spacing: 30) {
                    Text("Code Editor:")
                        .font(.largeTitle) // Change to a larger font, e.g., largeTitle
                        .fontWeight(.bold) // Optionally make it bold
                        .padding(.horizontal)

                    
                    // Language Picker
                    VStack(alignment: .leading) {
                        Text("Select Language:")
                            .font(.subheadline)
                            .padding(.horizontal)
                        Picker("Language", selection: $selectedLanguage) {
                            ForEach(languages, id: \.self) { language in
                                Text(language)
                            }
                        }
                        .onChange(of: selectedLanguage) { newLanguage in
                            // Update the script to the selected language's template
                            script = languageTemplates[newLanguage] ?? ""
                        }
                        .pickerStyle(MenuPickerStyle())
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding()
                    }
                    SyntaxHighlightingTextEditor(text: $script, language: selectedLanguage)
                        .frame(height: 300)
                        .border(Color.gray, width: 1)
                        .padding(.horizontal)

                  

                    // Execute Button
                    Button(action: executeCode) {
                        if isExecuting {
                            ProgressView()
                                .padding()
                        } else {
                            Text("Run Code")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isExecuting)
                    .padding(.horizontal)

                    // Output Section
                    VStack(alignment: .leading) {
                        Text("Output:")
                            .font(.headline)
                        ScrollView {
                            Text(output)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                        }
                        .frame(maxHeight: 150)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(Color(UIColor.systemGray5)) // Ensure correct placement here
        .edgesIgnoringSafeArea(.all)
    }

    // Clear the canvas
    func clearCanvas() {
        canvasView.drawing = PKDrawing()
        script = languageTemplates[selectedLanguage] ?? "" // Reset script to template
    }

    // Toggle pen and eraser
    func toggleTool() {
        if isEraserActive {
            canvasView.tool = PKInkingTool(.pen, color: penColor, width: penSize)
        } else {
            canvasView.tool = PKEraserTool(.vector)
        }
        isEraserActive.toggle()
    }

    // Recognizes handwriting and updates the script directly
    func recognizeHandwriting() {
        RecognizerHelper.recognizeText(from: canvasView) { recognizedText in
            DispatchQueue.main.async {
                if let insertionPoint = script.range(of: "Your code starts here") {
                    script.replaceSubrange(insertionPoint, with: "Your code starts here\n\(recognizedText)")
                } else {
                    script += "\n" + recognizedText
                }
            }
        }
    }

    // Execute the code
    func executeCode() {
        isExecuting = true
        output = "Executing..."

        guard let languageInfo = languageMap[selectedLanguage] else {
            output = "Error: Unsupported language selected."
            isExecuting = false
            return
        }

        jdoodleAPI.executeCode(script: script, language: languageInfo.language, versionIndex: languageInfo.versionIndex) { result in
            DispatchQueue.main.async {
                self.isExecuting = false
                switch result {
                case .success(let apiOutput):
                    self.output = apiOutput
                case .failure(let error):
                    self.output = "Error: \(error.localizedDescription)"
                }
            }
            
            func saveFileChanges() {
                    guard let index = fileManager.files.firstIndex(where: { $0.id == file.id }) else { return }
                    fileManager.files[index].script = script
                    fileManager.files[index].canvasDrawing = canvasView.drawing.dataRepresentation()
                    fileManager.saveToDisk()
                }
        }
    }
}
