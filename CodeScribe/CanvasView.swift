import SwiftUI
import PencilKit

struct ZoomableCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var penColor: UIColor
    @Binding var penSize: CGFloat

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = context.coordinator
        scrollView.backgroundColor = .white

        canvasView.drawingPolicy = .pencilOnly
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: penSize)
        canvasView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            canvasView.widthAnchor.constraint(equalToConstant: 1000), // Set a large width
            canvasView.heightAnchor.constraint(equalToConstant: 1000) // Set a large height
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: penSize)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableCanvasView

        init(_ parent: ZoomableCanvasView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return parent.canvasView
        }
    }
}
