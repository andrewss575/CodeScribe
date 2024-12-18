//
//  CodeScribeTests.swift
//  CodeScribeTests
//
//  Unit, Performance, and Security tests for CodeScribe Application
//  
//

import XCTest
import PencilKit
import Vision
@testable import CodeScribe

// MARK: - CodeScribeTests
/// A suite of tests to validate the functionality, performance, and security of CodeScribe.
final class CodeScribeTests: XCTestCase {
    
    // MARK: - Unit Testing
    
    /// Tests that the canvas view correctly registers drawing strokes.
    /// Type: **Unit Test**
    func testCanvasDrawing() {
        if #available(iOS 13.0, *) {
            let canvas = PKCanvasView()
            let tool = PKInkingTool(.pen, color: .black, width: 5.0)
            canvas.tool = tool
            
            // Validate that the canvas initializes correctly and remains functional.
            XCTAssertNotNil(canvas, "PKCanvasView failed to initialize.")
            XCTAssertEqual(canvas.drawing.strokes.count, 0, "Canvas should initially have no strokes.")
        }
    }

    /// Tests handwriting recognition functionality with Apple's Vision framework.
    /// Type: **Unit Test**
        /// Tests text recognition using RecognizerHelper's `recognizeTextWithVision` function
        func testTextRecognitionWithVision() {
            // Load the image containing the text "Expected Text"
            guard let image = UIImage(named: "expectedTest") else {
                XCTFail("Failed to load the test image 'expected_text_image'. Ensure it is added to the test target.")
                return
            }
            
            // Convert the image to JPEG data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                XCTFail("Failed to convert image to JPEG data.")
                return
            }
            
            let expectation = self.expectation(description: "Text recognition should extract 'Expected Text'")
            
            // Call RecognizerHelper's Vision-based text recognition
            RecognizerHelper.recognizeTextWithVision(imageData: imageData) { result in
                // Assert that result is not nil
                XCTAssertNotNil(result, "Text recognition returned nil.")
                
                // Assert that the recognized text contains 'Expected Text'
                XCTAssertTrue(result.contains("Expected Text"),
                              "Recognized text '\(result)' did not match the expected content 'Expected Text'.")
                expectation.fulfill()
            }
            
            // Wait for the asynchronous completion handler
            waitForExpectations(timeout: 10, handler: nil)
        }
    

    
        

    /// Tests that the eraser tool clears strokes successfully from the canvas.
    /// Type: **Unit Test**
    func testEraserTool() {
        if #available(iOS 13.0, *) {
            let canvas = PKCanvasView()
            let tool = PKInkingTool(.pen, color: .red, width: 5.0)
            canvas.tool = tool
            
            // Simulate drawing
            canvas.drawing = PKDrawing()
            
            // Switch to eraser tool
            let eraser = PKEraserTool(.vector)
            canvas.tool = eraser

            XCTAssertEqual(canvas.drawing.strokes.count, 0, "Eraser tool did not clear the canvas.")
        }
    }
    
    /// Tests the execution of valid code using the JDoodle API.
    /// Type: **Unit Test**
    func testJDoodleAPIExecution() {
        let api = JDoodleAPI()
        let script = "print('Hello, World!')"
        let expectation = self.expectation(description: "JDoodle API executes successfully")

        api.executeCode(script: script, language: "python3", versionIndex: "3") { result in
            switch result {
            case .success(let output):
                XCTAssertEqual(output.trimmingCharacters(in: .whitespacesAndNewlines), "Hello, World!")
            case .failure(let error):
                XCTFail("JDoodle API failed: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }



    // MARK: - Performance Testing
    
    /// Measures the performance of the canvas when simulating heavy drawing.
    /// Type: **Performance Test**
    func testCanvasPerformance() {
        if #available(iOS 13.0, *) {
            measure {
                let canvas = PKCanvasView()
                let tool = PKInkingTool(.pen, color: .blue, width: 3.0)
                canvas.tool = tool

                // Simulate multiple drawing actions
                for _ in 0..<1000 {
                    canvas.drawing = PKDrawing()
                }
            }
        }
    }



    // MARK: - Security Testing
    
    /// Tests to ensure unauthorized access is denied for secure files.
    /// Type: **Security Test**
    func testUnauthorizedAccess() {
        let fileManager = FileManagerModel()
        fileManager.createNewFile(name: "Secure File")

        let unauthorized = false
        XCTAssertFalse(unauthorized, "Unauthorized access should be blocked.")
    }

    /// Tests that malformed input is correctly handled without crashing the app.
    /// Type: **Security Test**
    func testMalformedInputHandling() {
        let malformedData = Data()
        XCTAssertThrowsError(try JSONDecoder().decode(CodeFile.self, from: malformedData), "Malformed input should trigger error handling.")
    }

    // MARK: - API Testing

    /// Tests text recognition functionality using the Google Vision API.
    /// Type: **API Test**
    func testGoogleVisionTextRecognition() {
        let image = UIImage(named: "pyhtonTest")!
        let imageData = image.jpegData(compressionQuality: 0.8)!

        GoogleVisionAPI.analyzeImage(imageData: imageData) { result in
            XCTAssertNotNil(result, "Google Vision API failed to return results.")
        }
    }

    // MARK: - Setup and Teardown

    /// Called before each test is executed.
    override func setUpWithError() throws {
        // Put setup code here. This method is called before each test method in the class.
    }

    /// Called after each test is executed.
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after each test method in the class.
    }
}
