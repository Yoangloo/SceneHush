import AppKit
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: swift GenerateIcon.swift <assets-directory>\n", stderr)
    exit(2)
}
let assets = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let iconset = assets.appendingPathComponent("SceneHush.iconset", isDirectory: true)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

func render(_ pixels: Int, to output: URL) throws {
    guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                                       bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                       isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0,
                                       bitsPerPixel: 0),
          let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(domain: "IconRendering", code: 1)
    }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    let scale = CGFloat(pixels) / 1024
    context.cgContext.scaleBy(x: scale, y: scale)
    context.imageInterpolation = .high

    let background = NSBezierPath(roundedRect: NSRect(x: 42, y: 42, width: 940, height: 940),
                                  xRadius: 210, yRadius: 210)
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.17)
    shadow.shadowBlurRadius = 26
    shadow.shadowOffset = NSSize(width: 0, height: -9)
    shadow.set()
    NSColor(calibratedRed: 0.025, green: 0.055, blue: 0.10, alpha: 1).setFill()
    background.fill()
    NSShadow().set()
    NSGradient(colors: [NSColor(calibratedRed: 0.08, green: 0.15, blue: 0.22, alpha: 1),
                        NSColor(calibratedRed: 0.025, green: 0.055, blue: 0.11, alpha: 1)])?
        .draw(in: background, angle: -70)

    let quiet = NSColor(calibratedRed: 0.52, green: 0.66, blue: 0.72, alpha: 0.50)
    let accent = NSColor(calibratedRed: 0.68, green: 0.97, blue: 0.83, alpha: 1)
    func corner(_ points: [NSPoint], color: NSColor, width: CGFloat) {
        let path = NSBezierPath()
        path.lineWidth = width
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: points[0])
        for point in points.dropFirst() { path.line(to: point) }
        color.setStroke()
        path.stroke()
    }
    corner([NSPoint(x: 245, y: 626), NSPoint(x: 245, y: 755), NSPoint(x: 374, y: 755)], color: quiet, width: 26)
    corner([NSPoint(x: 650, y: 755), NSPoint(x: 779, y: 755), NSPoint(x: 779, y: 626)], color: quiet, width: 26)
    corner([NSPoint(x: 245, y: 398), NSPoint(x: 245, y: 269), NSPoint(x: 374, y: 269)], color: quiet, width: 26)
    corner([NSPoint(x: 650, y: 269), NSPoint(x: 779, y: 269), NSPoint(x: 779, y: 398)], color: accent, width: 34)

    // A crescent drawn as one path preserves the gradient under its open side.
    let crescent = NSBezierPath()
    crescent.move(to: NSPoint(x: 582, y: 679))
    crescent.curve(to: NSPoint(x: 650, y: 386),
                   controlPoint1: NSPoint(x: 433, y: 621), controlPoint2: NSPoint(x: 451, y: 426))
    crescent.curve(to: NSPoint(x: 362, y: 488),
                   controlPoint1: NSPoint(x: 531, y: 294), controlPoint2: NSPoint(x: 354, y: 358))
    crescent.curve(to: NSPoint(x: 582, y: 679),
                   controlPoint1: NSPoint(x: 350, y: 614), controlPoint2: NSPoint(x: 454, y: 711))
    crescent.close()
    NSColor(calibratedRed: 0.89, green: 0.96, blue: 0.97, alpha: 1).setFill()
    crescent.fill()

    NSGraphicsContext.restoreGraphicsState()
    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconRendering", code: 2)
    }
    try png.write(to: output)
}

for size in [16, 32, 128, 256, 512] {
    try render(size, to: iconset.appendingPathComponent("icon_\(size)x\(size).png"))
    try render(size * 2, to: iconset.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
}
try render(1024, to: assets.appendingPathComponent("SceneHush.png"))

