import AppKit
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: swift GenerateIcon.swift <assets-directory>\n", stderr)
    exit(2)
}
let assets = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let iconset = assets.appendingPathComponent("SceneHush.iconset", isDirectory: true)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

private func color(_ hex: UInt32, alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: alpha)
}

private func gradient(_ colors: [NSColor], in path: NSBezierPath, angle: CGFloat) {
    NSGradient(colors: colors)?.draw(in: path, angle: angle)
}

private func shadow(_ blur: CGFloat, offset: CGFloat, opacity: CGFloat) {
    let value = NSShadow()
    value.shadowColor = color(0x192C48, alpha: opacity)
    value.shadowBlurRadius = blur
    value.shadowOffset = NSSize(width: 0, height: offset)
    value.set()
}

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
    context.cgContext.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
    context.imageInterpolation = .high

    let tile = NSBezierPath(roundedRect: NSRect(x: 44, y: 44, width: 936, height: 936),
                            xRadius: 214, yRadius: 214)
    shadow(28, offset: -10, opacity: 0.20)
    color(0xE2E9EF).setFill()
    tile.fill()
    NSShadow().set()
    gradient([color(0xF9F6EE), color(0xEEF1F5), color(0xC8D5E3)], in: tile, angle: -57)

    // The warm and cool light belongs to the same day / night switch.
    NSGraphicsContext.saveGraphicsState()
    tile.addClip()
    if pixels >= 128 {
        // Deterministic grain, baked into the asset; no image or runtime dependency.
        for index in 0..<2200 {
            let x = CGFloat((index * 353 + 73) % 936) + 44
            let y = CGFloat((index * 227 + 191) % 936) + 44
            color(0x405572, alpha: 0.020).setFill()
            NSBezierPath(ovalIn: NSRect(x: x, y: y, width: 1.3, height: 1.3)).fill()
        }
    }
    NSGraphicsContext.restoreGraphicsState()
    color(0xFFFFFF, alpha: 0.72).setStroke()
    tile.lineWidth = pixels <= 32 ? 6 : 3
    tile.stroke()

    let shell = NSBezierPath(roundedRect: NSRect(x: 135, y: 321, width: 754, height: 382),
                             xRadius: 191, yRadius: 191)
    shadow(36, offset: -22, opacity: 0.23)
    color(0xEDF0F2).setFill()
    shell.fill()
    NSShadow().set()
    gradient([color(0xFFFFFF), color(0xB0BECF)], in: shell, angle: -90)

    let track = NSBezierPath(roundedRect: NSRect(x: 153, y: 339, width: 718, height: 346),
                             xRadius: 173, yRadius: 173)
    gradient([color(0xEED3A7), color(0xB3C6D8), color(0x667E9D)], in: track, angle: 0)
    color(0x4B607D, alpha: 0.19).setStroke()
    track.lineWidth = 4
    track.stroke()

    let sunCenter = NSPoint(x: 337, y: 512)
    let sun = NSBezierPath(ovalIn: NSRect(x: sunCenter.x - 45, y: sunCenter.y - 45, width: 90, height: 90))
    color(0x9A602B).setFill()
    sun.fill()
    let rays = NSBezierPath()
    rays.lineWidth = pixels <= 32 ? 18 : 12
    rays.lineCapStyle = .round
    for index in 0..<8 {
        let angle = CGFloat(index) * .pi / 4
        rays.move(to: NSPoint(x: sunCenter.x + cos(angle) * 71, y: sunCenter.y + sin(angle) * 71))
        rays.line(to: NSPoint(x: sunCenter.x + cos(angle) * 91, y: sunCenter.y + sin(angle) * 91))
    }
    color(0x9A602B).setStroke()
    rays.stroke()

    let thumb = NSBezierPath(ovalIn: NSRect(x: 543, y: 363, width: 298, height: 298))
    shadow(24, offset: -8, opacity: 0.32)
    color(0x213A5D).setFill()
    thumb.fill()
    NSShadow().set()
    gradient([color(0x466386), color(0x172F50), color(0x152C49)], in: thumb, angle: -80)
    color(0xFFFFFF, alpha: 0.60).setStroke()
    thumb.lineWidth = pixels <= 32 ? 7 : 4
    thumb.stroke()
    if pixels >= 128 {
        let glint = NSBezierPath()
        glint.appendArc(withCenter: NSPoint(x: 692, y: 512), radius: 143,
                        startAngle: 32, endAngle: 144, clockwise: false)
        color(0xFFFFFF, alpha: 0.54).setStroke()
        glint.lineWidth = 3
        glint.lineCapStyle = .round
        glint.stroke()
    }

    // One closed crescent keeps the blue glass visible through its open side.
    let moon = NSBezierPath()
    moon.move(to: NSPoint(x: 709, y: 599))
    moon.curve(to: NSPoint(x: 760, y: 456),
               controlPoint1: NSPoint(x: 651, y: 575), controlPoint2: NSPoint(x: 675, y: 480))
    moon.curve(to: NSPoint(x: 623, y: 500),
               controlPoint1: NSPoint(x: 697, y: 409), controlPoint2: NSPoint(x: 621, y: 441))
    moon.curve(to: NSPoint(x: 709, y: 599),
               controlPoint1: NSPoint(x: 619, y: 554), controlPoint2: NSPoint(x: 657, y: 600))
    moon.close()
    color(0xFFF6DD).setFill()
    moon.fill()

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
