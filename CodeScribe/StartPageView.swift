//
// StartPageView.swift
//
// This file defines the `StartPageView`, the entry point of the CodeScribe app.
// It introduces the app with a welcoming layout, description, and a "Get Started" button
// that transitions to the main `ContentView`.
//

import SwiftUI

// MARK: - StartPageView

/// The entry point view for the CodeScribe app, featuring an introduction and navigation to the main content.
struct StartPageView: View {
    // State to track if the user clicked "Get Started"
    @State private var showContentView = false // Toggles navigation to `ContentView`

    var body: some View {
        Group { // Conditional rendering based on state
            if showContentView {
                ContentView() // Navigate to ContentView after clicking "Get Started"
            } else {
                HStack { // Main layout with two columns
                    // MARK: - Left Column: Text Content
                    VStack(alignment: .leading, spacing: 40) { // Increased spacing between elements
                        // Header Section
                        VStack(alignment: .leading, spacing: 20) { // Spacing for header elements
                            Text("Welcome to") // Introductory text
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)

                            Text("CodeScribe") // App name with prominent styling
                                .font(.system(size: 80)) // Large font size for emphasis
                                .fontWeight(.bold)
                                .foregroundColor(.blue) // Blue color for branding
                        }

                        // App Description Section
                        VStack(alignment: .leading, spacing: 30) { // Increased spacing between lines
                            Text("Your All-in-One Coding Assistant") // Subtitle emphasizing app functionality
                                .font(.title)
                                .foregroundColor(.black)

                            Text("""
Draw your code on the canvas, convert it to typed code, and execute it instantly. Perfect for developers, students, and anyone who wants to bridge handwriting and code execution seamlessly.
""")
                                .font(.title3) // Description text with readable font size
                                .foregroundColor(.gray)
                                .padding(.trailing, 40) // Adds space for cleaner layout
                        }

                        Spacer() // Pushes content upwards

                        // "Get Started" Button
                        Button(action: {
                            withAnimation { // Animates the transition to ContentView
                                showContentView = true
                            }
                        }) {
                            Text("Get Started") // Button label
                                .font(.title)
                                .fontWeight(.semibold)
                                .frame(maxWidth: 250, maxHeight: 70) // Large button dimensions
                                .background(Color.blue) // Blue background for branding
                                .foregroundColor(.white) // White text for contrast
                                .cornerRadius(15) // Rounded corners for button
                                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5) // Shadow for depth
                        }

                        Spacer() // Pushes content upwards

                        // Footer Section
                        VStack(alignment: .leading, spacing: 10) { // Spacing for footer content
                            Divider() // Horizontal separator line
                                .background(Color.gray)

                            Text("© 2024 CodeScribe") // Copyright notice
                                .font(.footnote)
                                .foregroundColor(.gray)

                            Text("All rights reserved.") // Legal disclaimer
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(60) // Adds padding around the left column
                    .frame(maxWidth: .infinity, alignment: .leading) // Aligns content to the left

                    // MARK: - Right Column: Image Content
                    VStack {
                        Spacer() // Pushes the image downwards

                        // Display an app-related image
                        Image("pngegg(1)") // Replace with your asset name
                            .resizable() // Allows resizing of the image
                            .scaledToFit() // Maintains aspect ratio while fitting within the frame
                            .frame(width: 500, height: 500) // Sets the image size
                            .cornerRadius(30) // Rounded corners for the image
                            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5) // Adds a shadow for depth
                            .padding() // Adds padding around the image

                        Spacer() // Pushes the image upwards
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Centers the image within the column
                }
                .background(Color(UIColor.systemGray6)) // Sets a light gray background
                .edgesIgnoringSafeArea(.all) // Extends the background to cover the screen edges
            }
        }
    }
}

// MARK: - Preview

/// Provides a live preview of `StartPageView` in Xcode.
struct StartPageView_Previews: PreviewProvider {
    static var previews: some View {
        StartPageView() // Displays the StartPageView in preview
    }
}
