//
// SyntaxHighlighter.swift
//
// This file defines the `SyntaxHighlightingTextEditor` component, which is a SwiftUI wrapper for a UITextView.
// It provides syntax highlighting for various programming languages using the Highlightr library.
//

import SwiftUI
import Highlightr // External library for syntax highlighting

// MARK: - SyntaxHighlightingTextEditor

/// A SwiftUI wrapper for `UITextView` that provides syntax highlighting for code editing.
struct SyntaxHighlightingTextEditor: UIViewRepresentable {
    @Binding var text: String // The text to display and edit
    var language: String // The programming language for syntax highlighting

    // MARK: - UIViewRepresentable Methods

    /// Creates the `UITextView` instance and configures it.
    /// - Parameter context: The context provided by SwiftUI.
    /// - Returns: A configured `UITextView` instance.
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator // Assigns the Coordinator as the delegate
        textView.isEditable = true // Allows the user to edit the text
        textView.isScrollEnabled = true // Enables scrolling for large content
        textView.backgroundColor = .white // Sets the background color of the text view
        textView.textColor = .white // Sets the default text color
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular) // Uses a monospaced font

        // Apply initial syntax highlighting
        context.coordinator.applySyntaxHighlighting(to: textView, with: text, language: language)
        return textView
    }

    /// Updates the `UITextView` when the SwiftUI view's state changes.
    /// - Parameters:
    ///   - uiView: The `UITextView` instance.
    ///   - context: The context provided by SwiftUI.
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Reapply syntax highlighting whenever the text or language changes
        context.coordinator.applySyntaxHighlighting(to: uiView, with: text, language: language)
    }

    /// Creates a Coordinator instance to handle UITextView delegation and syntax highlighting.
    /// - Returns: A new `Coordinator` instance.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    /// A helper class to manage `UITextView` delegation and syntax highlighting logic.
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SyntaxHighlightingTextEditor // Reference to the parent SwiftUI view

        /// Initializes the Coordinator with a reference to the parent view.
        /// - Parameter parent: The parent `SyntaxHighlightingTextEditor` instance.
        init(_ parent: SyntaxHighlightingTextEditor) {
            self.parent = parent
        }

        /// Updates the SwiftUI binding when the text changes in the `UITextView`.
        /// - Parameter textView: The `UITextView` instance.
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text // Sync the updated text back to the SwiftUI binding
        }

        /// Applies syntax highlighting to the provided `UITextView`.
        /// - Parameters:
        ///   - textView: The `UITextView` instance.
        ///   - text: The text content to highlight.
        ///   - language: The programming language for syntax highlighting.
        func applySyntaxHighlighting(to textView: UITextView, with text: String, language: String) {
            let highlightr = Highlightr() // Initialize the syntax highlighter
            highlightr?.setTheme(to: "xcode") // Set the highlighting theme (e.g., "xcode")
            
            // Attempt to highlight the text
            if let highlighted = highlightr?.highlight(text, as: language) {
                textView.attributedText = highlighted // Apply highlighted text
            } else {
                textView.text = text // Fallback: Display plain text if highlighting fails
            }
        }
    }
}
