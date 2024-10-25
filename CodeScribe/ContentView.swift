import SwiftUI
import PencilKit
import Vision

struct ContentView: View {
    // This declares a state variable, canvasView, that stores an instance of
    // PKCanvasView (PencilKit’s canvas). This is the drawing area where users
    // can write and draw with their finger or stylus.
    // The @State attribute tells SwiftUI to track changes to canvasView, so
    // when the user draws on it, the UI can update automatically if needed.
    @State private var canvasView = PKCanvasView()
    
    // This state variable tracks whether the eraser tool is active.
    @State private var isEraserActive = false
    
    // This state variable stores the recognized text from Vision framework.
    @State private var recognizedText = ""
    
    // Defines layout and content of ContentView
    var body: some View {
        VStack { // Creates a vertical stack layout
            // Adds text to canvas and says it's a headline with padding
            Text("Welcome to CodeScribe: Write or Draw Notes Below")
                .font(.headline)
                .padding()
            
            // Integrate PencilKit canvas
            // CanvasView is a function we define later. It creates a canvas
            // that allows drawing on it with a finger or stylus.
            CanvasView(canvasView: $canvasView)
                .frame(height: 300)
                .cornerRadius(10)
                .padding()
            
            // Adding button to clear
            Button(action: {
                print("Clear Note")
                // Calls the function to clear the notes
                clearCanvas() // A function we will implement to clear the notes
            }) {
                Text("Clear Note")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Adding button to toggle between Pen and Eraser
            Button(action: {
                toggleTool() // Calls the function to switch between pen and eraser
            }) {
                Text(isEraserActive ? "Switch to Pen" : "Switch to Eraser")
                    .padding()
                    .background(isEraserActive ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Adding button to recognize handwriting
            Button(action: {
                recognizeHandwriting() // Calls the function to recognize handwriting using Vision
                print("Recognized text: \(recognizedText)")
            }) {
                Text("Convert to Text")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Display recognized text
                       ScrollView {
                           Text("Recognized Text: \(recognizedText)")
                               .padding()
                               .background(Color.gray.opacity(0.2))
                               .cornerRadius(10)
                               .padding()
                       }
                       .frame(maxHeight: 200) // Set a fixed max height for ScrollView to ensure it appears properly
                   }
                   .padding() // Add padding to the entire VStack to improve layout
        }
    
    
    // Function to clear the canvas
    func clearCanvas() {
        canvasView.drawing = PKDrawing()  // This resets the canvas to an empty drawing
    }
    
    // Function to toggle between pen and eraser tool
    func toggleTool() {
        if isEraserActive {
            // Switch to pen
            canvasView.tool = PKInkingTool(.pen, color: .black, width: 2)
        } else {
            // Switch to eraser
            canvasView.tool = PKEraserTool(.vector)
        }
        isEraserActive.toggle()  // Toggle the eraser state
    }
    
    // Function to recognize handwriting using Vision framework
    // Function to recognize handwriting using Vision framework
    func recognizeHandwriting() {
        // Capture the current drawing on the canvas as an image
        let bounds = canvasView.bounds
        let scale = UIScreen.main.scale * 10  // Increase scale to improve image quality
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            canvasView.layer.render(in: context)
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Failed to get image from current context")
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()
        
        guard let cgImage = image.cgImage else {
            print("Failed to convert UIImage to CGImage")
            return
        }
        
        // Create a request for text recognition
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Text recognition error: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No text recognized")
                return
            }
            
            var recognizedTextString = ""
            for observation in observations {
                if let bestCandidate = observation.topCandidates(1).first {
                    recognizedTextString += bestCandidate.string + "\n"
                }
            }
            
            // Update the recognized text in the main thread
            DispatchQueue.main.async {
                self.recognizedText = recognizedTextString
                print(recognizedTextString)
            }
        }
        
        request.recognitionLevel = .accurate  // Set the recognition level to accurate for better results
        //request.usesLanguageCorrection = true // Enable language correction
        request.usesLanguageCorrection = false // Disable language correction for code recognition
        request.revision = VNRecognizeTextRequestRevision3 // Use a newer revision for improved recognition
        
        // Create an image request handler and perform the request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                //print ("we try")
            } catch {
                print("Failed to perform text recognition: \(error.localizedDescription)")
            }
        }
    }
}

// This defines a new struct called CanvasView, which is responsible for
// integrating a UIKit-based PKCanvasView into SwiftUI. UIViewRepresentable is a
// protocol that lets you use UIKit views (like PKCanvasView) in a SwiftUI app.
struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView // Binds ContentView and CanvasView

    // Part of UIViewRepresentable and is called when the SwiftUI view is
    // created. It returns the PKCanvasView that will be displayed.
    func makeUIView(context: Context) -> PKCanvasView {
        // This allows only stylus input to draw on the canvas.
        canvasView.drawingPolicy = .pencilOnly
        // Sets the drawing tool to a black pen with a width of 5.
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 1)
        // Returns the canvas to be displayed
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Handle any updates to the canvas view
    }
}

// Used by Xcode to preview the UI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
