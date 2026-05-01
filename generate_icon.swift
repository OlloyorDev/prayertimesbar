#!/usr/bin/env swift
import AppKit
import Foundation

let sizes: [(Int, Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

let iconsetDir = "AppIcon.iconset"
try? FileManager.default.removeItem(atPath: iconsetDir)
try FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

func render(size: Int, scale: Int) -> NSImage {
    let pixelSize = size * scale
    let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    image.lockFocus()

    // Background — gradient (dark green → black)
    let bgRect = NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize)
    let path = NSBezierPath(roundedRect: bgRect,
                            xRadius: CGFloat(pixelSize) * 0.22,
                            yRadius: CGFloat(pixelSize) * 0.22)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.07, green: 0.35, blue: 0.27, alpha: 1.0),
        NSColor(red: 0.02, green: 0.15, blue: 0.12, alpha: 1.0)
    ])
    path.addClip()
    gradient?.draw(in: bgRect, angle: 270)

    // SF Symbol "moon.stars.fill" — render via NSImage
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: CGFloat(pixelSize) * 0.55,
                                                    weight: .regular)
    if let symbol = NSImage(systemSymbolName: "moon.stars.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(symbolConfig) {
        let tinted = NSImage(size: symbol.size, flipped: false) { rect in
            symbol.draw(in: rect)
            NSColor(white: 1.0, alpha: 1.0).set()
            rect.fill(using: .sourceAtop)
            return true
        }
        let symSize = tinted.size
        let drawRect = NSRect(
            x: (CGFloat(pixelSize) - symSize.width) / 2,
            y: (CGFloat(pixelSize) - symSize.height) / 2,
            width: symSize.width,
            height: symSize.height
        )
        tinted.draw(in: drawRect)
    }

    image.unlockFocus()
    return image
}

func savePNG(image: NSImage, path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed to encode \(path)")
        return
    }
    try? png.write(to: URL(fileURLWithPath: path))
}

for (size, scale) in sizes {
    let image = render(size: size, scale: scale)
    let suffix = scale == 1 ? "" : "@2x"
    let filename = "\(iconsetDir)/icon_\(size)x\(size)\(suffix).png"
    savePNG(image: image, path: filename)
    print("✓ \(filename)")
}

// Run iconutil
let task = Process()
task.launchPath = "/usr/bin/iconutil"
task.arguments = ["-c", "icns", iconsetDir, "-o", "AppIcon.icns"]
task.launch()
task.waitUntilExit()

if task.terminationStatus == 0 {
    print("\n✅ AppIcon.icns yaratildi")
    try? FileManager.default.removeItem(atPath: iconsetDir)
} else {
    print("\n❌ iconutil xatosi")
}
