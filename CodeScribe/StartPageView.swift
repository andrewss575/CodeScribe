import SwiftUI

struct StartPageView: View {
    // State to track if the user clicked "Get Started"
    @State private var showContentView = false

    var body: some View {
        Group {
            if showContentView {
                ContentView() // Navigate to ContentView after clicking "Get Started"
            } else {
                HStack {
                    // Left Column: Text Content
                    VStack(alignment: .leading, spacing: 40) { // Increased spacing
                        // Header Section
                        VStack(alignment: .leading, spacing: 20) { // Increased spacing
                            Text("Welcome to")
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)

                            Text("CodeScribe")
                                .font(.system(size: 80)) // Made "CodeScribe" larger
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }

                        // App Description
                        VStack(alignment: .leading, spacing: 30) { // Increased spacing
                            Text("Your All-in-One Coding Assistant")
                                .font(.title)
                                .foregroundColor(.black)

                            Text("""
Draw your code on the canvas, convert it to typed code, and execute it instantly. Perfect for developers, students, and anyone who wants to bridge handwriting and code execution seamlessly.
""")
                                .font(.title3) // Increased font size
                                .foregroundColor(.gray)
                                .padding(.trailing, 40) // Increased padding for better layout
                        }

                        Spacer()

                        // "Get Started" Button
                        Button(action: {
                            withAnimation {
                                showContentView = true // Navigate to ContentView
                            }
                        }) {
                            Text("Get Started")
                                .font(.title)
                                .fontWeight(.semibold)
                                .frame(maxWidth: 250, maxHeight: 70) // Larger button
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                        }

                        Spacer()

                        // Footer Section
                        VStack(alignment: .leading, spacing: 10) { // Increased spacing
                            Divider()
                                .background(Color.gray)

                            Text("© 2024 CodeScribe")
                                .font(.footnote)
                                .foregroundColor(.gray)

                            Text("All rights reserved.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(60) // Increased padding
                    .frame(maxWidth: .infinity, alignment: .leading) // Align content to the left

                    // Right Column: Image Content
                    VStack {
                        Spacer()

                        // Replace "Placeholder Image" with your actual asset
                        Image("pngegg(1)") // Replace with your image name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 500) // Increased size
                            .cornerRadius(30) // Increased corner radius
                            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding()

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Center the image content
                }
                .background(Color(UIColor.systemGray6))
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

// Preview
struct StartPageView_Previews: PreviewProvider {
    static var previews: some View {
        StartPageView()
    }
}
