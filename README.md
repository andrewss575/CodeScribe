# CodeScribe

CodeScribe is an iPad-based note-taking application designed specifically for computer science students. It allows users to draw notes using their stylus, convert handwriting into digital text, embed code, and even compile code directly within the note. This README provides an overview of the application, its key features, the technology stack used, and the testing approach.

## Features

- **Canvas Drawing**: Users can draw on the canvas using a stylus, making it perfect for handwritten notes, diagrams, or quick sketches.
- **Handwriting to Text Conversion**: CodeScribe leverages Apple's Vision framework to convert handwritten notes into digital text, allowing users to keep their notes organized and searchable.
- **Code Embedding and Compilation**: Users can embed code directly into their notes and use a compiler API to compile and run code snippets.
- **Eraser Tool**: Users can easily toggle between pen and eraser tools, providing a flexible way to edit their drawings and notes.
- **Export Notes**: Users can export their notes in different formats, including PDF and PNG, for sharing or storage purposes.

## Technology Stack

- **Swift and SwiftUI**: Used for front-end development to create the user interface.
- **PencilKit**: Used for creating the drawing canvas that allows users to draw or write with their stylus.
- **Vision Framework**: Used for handwriting recognition, converting handwritten content into digital text.
- **Compiler API**: Used to compile and run code directly from the note-taking application.
- **Xcode**: Development environment for building, testing, and running the application.

## Installation Instructions

To install and set up CodeScribe on your local device, follow these steps:

1. **Clone the Repository**:
   ```
   git clone https://github.com/andrewss575/CodeScribe.git
   ```

2. **Open the Project**:
   - Open the `.xcodeproj` file in Xcode.

3. **Install Dependencies**:
   - Ensure you have Xcode version X.X or above.
   - Install any required dependencies using Swift Package Manager.

4. **Run the Project**:
   - Build and run the project on an iOS simulator or connected iPad device.

## Testing Strategies and Methodologies

To ensure the reliability, security, and overall quality of CodeScribe, the following testing strategies and methodologies have been implemented:

### Unit Tests

- **Canvas Drawing Test**: Tests whether the user can draw on the canvas without any issues. 
  - *Expected Result*: The canvas should register all pen strokes accurately.

- **Text Conversion Test**: Tests the Vision integration to convert handwriting into digital text.
  - *Expected Result*: Handwritten text is successfully converted into readable text.

- **Eraser Tool Toggle**: Tests the functionality of switching between pen and eraser tools.
  - *Expected Result*: The eraser successfully removes any drawings or text on the canvas.

- **API Text Conversion to Compiler**: Tests the functionality of taking text converted from Vision and running it in the compiler.
  - *Expected Result*: Handwritten text is accurately converted to code, and the code compiles and runs successfully.

### Performance Tests

- **Drawing Load Test**: Tests the app's performance when handling high-density drawings.
  - *Expected Result*: No lag or stuttering while drawing.

- **Text Recognition Load Test**: Tests the efficiency of text recognition with a large volume of handwritten content.
  - *Expected Result*: Text recognition completes without long processing delays.

### Security Tests

- **Data Privacy Test**: Ensures that only the authorized user can access and edit their notes.
  - *Expected Result*: Unauthorized access is blocked.

- **Input Validation Test**: Ensures that no invalid input can cause crashes or unexpected behavior.
  - *Expected Result*: Proper error messages are provided without crashing.

## Evidence of Bugs and Fixes

- **Eraser Tool Bug**: Initially, the eraser failed to remove all pen strokes effectively. This issue was resolved by refining the eraser's interaction with the canvas layer.

- **Vision Framework Conversion Issue**: The Vision framework had issues converting handwriting to text when images were captured from the canvas as CGImage. This was resolved by converting the image to PNG format and adjusting the orientation and quality, improving the Vision framework's recognition.

- **Code Symbol Recognition Issue**: The Vision framework struggled to recognize specific code symbols like `{`, `;`, and other syntax. This bug remains unresolved, but potential solutions include integrating a specialized framework for code recognition or adding an ML layer to preprocess images for better accuracy.

## Upcoming Tasks

- **Improve Code Symbol Recognition**: Explore alternative frameworks or APIs that are more advanced in reading code, or create a machine learning model to enhance Vision's implementation for code-specific symbols.

- **Additional Features**: Implement more robust text-editing capabilities, including better formatting options and customizable tools for note-taking.

## Contributions

If you wish to contribute to the project, please feel free to fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for more information.

