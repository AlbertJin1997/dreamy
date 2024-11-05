import SwiftUI

struct PixelArtView: View {
    @State private var pixels: [[Color]] = Array(repeating: Array(repeating: .white, count: 16), count: 16)
    @State private var selectedColor: Color = .black
    @State private var lastSelectedColor: Color = .black
    @State private var selectedPixel: PixelPosition? = nil
    @State private var isErasing: Bool = false
    @State private var showingSaveAlert: Bool = false
    @State private var path: [CGPoint] = []
    @State private var pixelSize: CGFloat = 20
    @State private var gridSize: Int = 16
    
    var body: some View {
        VStack {
            Canvas { context, size in
                for row in 0..<gridSize {
                    for column in 0..<gridSize {
                        let rect = CGRect(
                            x: CGFloat(column) * pixelSize,
                            y: CGFloat(row) * pixelSize,
                            width: pixelSize,
                            height: pixelSize
                        )
                        context.fill(Path(rect), with: .color(pixels[row][column]))
                        context.stroke(Path(rect), with: .color(.black), lineWidth: 1)
                    }
                    
                    if !path.isEmpty {
                        var path = Path()
                        path.addLines(self.path)
                        context.stroke(path, with: .color(Color.red), lineWidth: 4)
                    }
                }
            }
            .frame(width: pixelSize * CGFloat(gridSize), height: pixelSize * CGFloat(gridSize))
            .border(Color.black)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let location = value.location
                        let column = Int(location.x / pixelSize)
                        let row = Int(location.y / pixelSize)
                        if row >= 0 && row < gridSize && column >= 0 && column < gridSize {
                            selectedPixel = PixelPosition(row: row, column: column)
                            if let pixel = selectedPixel {
                                pixels[pixel.row][pixel.column] = isErasing ? .white : selectedColor
                            }
                        }
                        path.append(location)
                    }.onEnded { _ in
                        path.removeAll()
                    }
            )
            
            ColorPicker("Pick a color", selection: $selectedColor)
                .padding()
            
            HStack {
                Button("Randomize") {
                    randomizePixels()
                }
                Button("Clear") {
                    clearPixels()
                }
                Button(action: {
                    selectedColor = .white
                }) {
                    Text("Erase")
                }
                .padding()
                
                Button("Save Image") {
                    saveImage()
                }
                .padding()
                
                Button("connect") {
                    NIOClient.shared.connect(host: "lucymocktrade.qiuer.cc", port: 9932)
                }
                .padding()
            }
            .padding()
            .alert(isPresented: $showingSaveAlert) {
                Alert(title: Text("Image Saved"), message: Text("Your pixel art has been saved to your photo library."), dismissButton: .default(Text("OK")))
            }
            
            VStack {
                Text("Pixel Size: \(Int(pixelSize))")
                Slider(value: $pixelSize, in: 10...20, step: 1)
            }
            .padding()
            
            VStack {
                Text("Grid Size: \(gridSize)")
                Slider(value: Binding(
                    get: { Double(gridSize) },
                    set: { gridSize = Int($0) }
                ), in: 8...16, step: 1)
            }
            .padding()
        }
    }
    
    private func randomizePixels() {
        pixels = pixels.map { row in
            row.map { _ in
                Color(
                    red: Double.random(in: 0...1),
                    green: Double.random(in: 0...1),
                    blue: Double.random(in: 0...1)
                )
            }
        }
    }
    
    private func clearPixels() {
        pixels = Array(repeating: Array(repeating: .white, count: gridSize), count: gridSize)
    }
    
    private func saveImage() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pixelSize * CGFloat(gridSize), height: pixelSize * CGFloat(gridSize)))
        let image = renderer.image { context in
            for row in 0..<gridSize {
                for column in 0..<gridSize {
                    let rect = CGRect(
                        x: CGFloat(column) * pixelSize,
                        y: CGFloat(row) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    context.cgContext.setFillColor(pixels[row][column].toUIColor().cgColor)
                    context.cgContext.fill(rect)
                    
                }
            }
            // 绘制整个大像素的边框
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(2) // 边框宽度
            let borderRect = CGRect(x: 0, y: 0, width: 320, height: 320)
            context.cgContext.stroke(borderRect)
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showingSaveAlert = true
    }
}

struct PixelPosition: Identifiable {
    let id = UUID()
    let row: Int
    let column: Int
}

extension Color {
    func toUIColor() -> UIColor {
        let components = self.cgColor?.components
        return UIColor(red: components?[0] ?? 1, green: components?[1] ?? 1, blue: components?[2] ?? 1, alpha: components?[3] ?? 1)
    }
}

struct ContentView: View {
    var body: some View {
        PixelArtView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
