//
// CanvasView.swift
//
// This file defines a SwiftUI view that wraps a PencilKit canvas within a zoomable UIScrollView.
// The canvas allows users to draw with a pen tool, customize pen color and size, and interact with it using Apple Pencil.
// It supports zooming and panning, making it ideal for detailed handwriting or drawing.
//

import SwiftUI
import PencilKit

// Represents a SwiftUI view that embeds a zoomable PKCanvasView
struct ZoomableCanvasView: UIViewRepresentable {
    // MARK: - Properties

    @Binding var canvasView: PKCanvasView // The PencilKit canvas view to render
    @Binding var penColor: UIColor // The selected pen color
    @Binding var penSize: CGFloat // The selected pen size

    // MARK: - UIViewRepresentable Methods

    // Creates and configures the UIScrollView containing the PKCanvasView
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView() // Scroll view to enable zooming and panning
        scrollView.minimumZoomScale = 1.0 // Minimum zoom scale (no zoom)
        scrollView.maximumZoomScale = 5.0 // Maximum zoom scale (5x zoom)
        scrollView.delegate = context.coordinator // Assigns the coordinator as the delegate
        scrollView.backgroundColor = .white // Sets the background color to white

        // Configure the PKCanvasView (drawing canvas)
        canvasView.drawingPolicy = .pencilOnly // Allows only Apple Pencil for drawing
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: penSize) // Sets the default pen tool
        canvasView.translatesAutoresizingMaskIntoConstraints = false // Allows manual layout constraints

        // Add the PKCanvasView as a subview of the scroll view
        scrollView.addSubview(canvasView)

        // Set constraints to define the size and position of the canvas
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            canvasView.widthAnchor.constraint(equalToConstant: 750), // Large canvas width
            canvasView.heightAnchor.constraint(equalToConstant: 750) // Large canvas height
        ])

        return scrollView
    }

    // Updates the PKCanvasView tool when bindings change (e.g., pen color or size)
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: penSize) // Updates pen tool
    }

    // Creates a Coordinator to manage zooming behavior in the UIScrollView
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator Class

    // Coordinator class to handle UIScrollView delegate methods
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableCanvasView // Reference to the parent ZoomableCanvasView

        // Initializes the coordinator with the parent view
        init(_ parent: ZoomableCanvasView) {
            self.parent = parent
        }

        // Specifies the view to zoom in the UIScrollView (the PKCanvasView)
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return parent.canvasView // Returns the canvas view as the zoomable content
        }
    }
}
