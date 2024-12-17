
import SwiftUI
import Highlightr

struct SyntaxHighlightingTextEditor: UIViewRepresentable {
    @Binding var text: String
    var language: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .white
        textView.textColor = .white
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        context.coordinator.applySyntaxHighlighting(to: textView, with: text, language: language)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.applySyntaxHighlighting(to: uiView, with: text, language: language)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SyntaxHighlightingTextEditor

        init(_ parent: SyntaxHighlightingTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func applySyntaxHighlighting(to textView: UITextView, with text: String, language: String) {
            let highlightr = Highlightr()
            highlightr?.setTheme(to: "xcode") // Choose your theme
            if let highlighted = highlightr?.highlight(text, as: language) {
                textView.attributedText = highlighted
            } else {
                textView.text = text // Fallback to plain text
            }
        }
    }
}
