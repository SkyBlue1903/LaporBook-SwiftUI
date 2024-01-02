import SwiftUI
import SDWebImageSwiftUI

struct ZoomableImageView: View {
  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero
  
  private let panSensitivity: CGFloat = 1.5
  
  private var maxOffset: CGSize {
    let imageWidth = (UIScreen.main.bounds.width * scale - UIScreen.main.bounds.width) / 2
    let imageHeight = (UIScreen.main.bounds.height * scale - UIScreen.main.bounds.height) / 2
    
    return CGSize(width: max(0, imageWidth), height: max(0, imageHeight))
  }
  
  var image: String
  
  var body: some View {
    WebImage(url: URL(string: image))
      .resizable()
      .scaledToFit()
      .gesture(
        SimultaneousGesture(
          MagnificationGesture()
            .onChanged { value in
              scale = lastScale * value
            }
            .onEnded { value in
              lastScale = scale
              if scale < 1 {
                withAnimation {
                  scale = 1
                  lastScale = 1
                  offset = .zero
                  lastOffset = .zero
                }
              }
            },
          DragGesture()
            .onChanged { value in
              offset.width = max(-maxOffset.width, min(lastOffset.width + value.translation.width * panSensitivity, maxOffset.width))
              offset.height = max(-maxOffset.height, min(lastOffset.height + value.translation.height * panSensitivity, maxOffset.height))
            }
            .onEnded { value in
              lastOffset = offset
            }
        )
      )
      .scaleEffect(scale)
      .offset(offset)
      .toolbar(.hidden, for: .tabBar)
      .navigationTitle("Foto Laporan")
      .navigationBarTitleDisplayMode(.inline)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ZoomableImageView(image: "")
  }
}
