import AppKit
import Foundation

let fileManager = FileManager.default
let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let iconsDir = root.appendingPathComponent("icons", isDirectory: true)

try fileManager.createDirectory(at: iconsDir, withIntermediateDirectories: true)

func image(for size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let background = NSGradient(colors: [
        NSColor(calibratedRed: 1.0, green: 0.96, blue: 0.97, alpha: 1),
        NSColor(calibratedRed: 1.0, green: 0.84, blue: 0.89, alpha: 1),
        NSColor(calibratedRed: 0.96, green: 0.64, blue: 0.75, alpha: 1)
    ])!
    background.draw(in: NSBezierPath(roundedRect: rect.insetBy(dx: size * 0.03, dy: size * 0.03), xRadius: size * 0.22, yRadius: size * 0.22), angle: -45)

    let trail = NSBezierPath()
    trail.move(to: CGPoint(x: size * 0.20, y: size * 0.60))
    trail.curve(to: CGPoint(x: size * 0.48, y: size * 0.64),
                controlPoint1: CGPoint(x: size * 0.28, y: size * 0.72),
                controlPoint2: CGPoint(x: size * 0.38, y: size * 0.70))
    trail.lineWidth = max(5, size * 0.05)
    NSColor.white.withAlphaComponent(0.42).setStroke()
    trail.lineCapStyle = .round
    trail.stroke()

    let trail2 = NSBezierPath()
    trail2.move(to: CGPoint(x: size * 0.14, y: size * 0.46))
    trail2.curve(to: CGPoint(x: size * 0.40, y: size * 0.50),
                 controlPoint1: CGPoint(x: size * 0.21, y: size * 0.56),
                 controlPoint2: CGPoint(x: size * 0.32, y: size * 0.55))
    trail2.lineWidth = max(3, size * 0.035)
    NSColor.white.withAlphaComponent(0.30).setStroke()
    trail2.lineCapStyle = .round
    trail2.stroke()

    let heart = NSBezierPath()
    heart.move(to: CGPoint(x: size * 0.50, y: size * 0.22))
    heart.curve(to: CGPoint(x: size * 0.23, y: size * 0.54),
                controlPoint1: CGPoint(x: size * 0.36, y: size * 0.34),
                controlPoint2: CGPoint(x: size * 0.23, y: size * 0.39))
    heart.curve(to: CGPoint(x: size * 0.35, y: size * 0.77),
                controlPoint1: CGPoint(x: size * 0.23, y: size * 0.68),
                controlPoint2: CGPoint(x: size * 0.28, y: size * 0.77))
    heart.curve(to: CGPoint(x: size * 0.50, y: size * 0.64),
                controlPoint1: CGPoint(x: size * 0.43, y: size * 0.77),
                controlPoint2: CGPoint(x: size * 0.50, y: size * 0.70))
    heart.curve(to: CGPoint(x: size * 0.65, y: size * 0.77),
                controlPoint1: CGPoint(x: size * 0.50, y: size * 0.70),
                controlPoint2: CGPoint(x: size * 0.57, y: size * 0.77))
    heart.curve(to: CGPoint(x: size * 0.77, y: size * 0.54),
                controlPoint1: CGPoint(x: size * 0.72, y: size * 0.77),
                controlPoint2: CGPoint(x: size * 0.77, y: size * 0.68))
    heart.curve(to: CGPoint(x: size * 0.50, y: size * 0.22),
                controlPoint1: CGPoint(x: size * 0.77, y: size * 0.39),
                controlPoint2: CGPoint(x: size * 0.64, y: size * 0.34))

    NSGraphicsContext.current?.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(calibratedRed: 0.72, green: 0.26, blue: 0.45, alpha: 0.35)
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.03)
    shadow.shadowBlurRadius = size * 0.06
    shadow.set()
    let heartGradient = NSGradient(colors: [
        NSColor(calibratedRed: 1.0, green: 0.32, blue: 0.55, alpha: 1),
        NSColor(calibratedRed: 0.85, green: 0.11, blue: 0.38, alpha: 1)
    ])!
    heartGradient.draw(in: heart, angle: -45)
    NSGraphicsContext.current?.restoreGraphicsState()

    let highlight = NSBezierPath(ovalIn: NSRect(x: size * 0.32, y: size * 0.62, width: size * 0.07, height: size * 0.07))
    NSColor.white.withAlphaComponent(0.85).setFill()
    highlight.fill()

    image.unlockFocus()
    return image
}

func writePNG(image: NSImage, to url: URL) throws {
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let data = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "icon-generator", code: 1)
    }

    try data.write(to: url)
}

for size in [16, 32, 48, 128] {
    let output = iconsDir.appendingPathComponent("icon\(size).png")
    try writePNG(image: image(for: CGFloat(size)), to: output)
    print("Generated \(output.path)")
}
