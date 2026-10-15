import AppKit

let size = CGSize(width: 1024, height: 1024)
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024,
                              bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                              isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 4096, bitsPerPixel: 32)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSColor(calibratedRed: 0.025, green: 0.042, blue: 0.058, alpha: 1).setFill()
NSBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
let center = CGPoint(x: 512, y: 512)
let ring = NSBezierPath(ovalIn: CGRect(x: 115, y: 115, width: 794, height: 794))
ring.lineWidth = 3
NSColor(calibratedRed: 0.34, green: 0.93, blue: 0.96, alpha: 0.25).setStroke()
ring.stroke()
for tick in 0..<72 {
    let angle = CGFloat(tick) / 72 * .pi * 2
    let outer: CGFloat = 385
    let inner: CGFloat = tick % 6 == 0 ? 361 : 374
    let path = NSBezierPath()
    path.move(to: CGPoint(x: center.x + cos(angle) * inner, y: center.y + sin(angle) * inner))
    path.line(to: CGPoint(x: center.x + cos(angle) * outer, y: center.y + sin(angle) * outer))
    path.lineWidth = tick % 6 == 0 ? 3 : 1.5
    NSColor(calibratedRed: 0.34, green: 0.93, blue: 0.96, alpha: tick % 6 == 0 ? 0.75 : 0.25).setStroke()
    path.stroke()
}
let amber = NSColor(calibratedRed: 1, green: 0.74, blue: 0.37, alpha: 1)
let deep = NSColor(calibratedRed: 0.32, green: 0.18, blue: 0.10, alpha: 1)
let horizon = NSBezierPath()
horizon.move(to: CGPoint(x: 230, y: 348)); horizon.line(to: CGPoint(x: 794, y: 348))
horizon.lineWidth = 3
NSColor(calibratedRed: 0.34, green: 0.93, blue: 0.96, alpha: 0.60).setStroke(); horizon.stroke()
let shock = NSBezierPath(ovalIn: CGRect(x: 240, y: 293, width: 544, height: 110))
shock.lineWidth = 3; shock.stroke()
let stem = NSBezierPath(roundedRect: CGRect(x: 466, y: 350, width: 92, height: 256), xRadius: 46, yRadius: 46)
NSGradient(starting: deep, ending: amber)!.draw(in: stem, angle: 90)
for (x, y, radius) in [(365.0,590.0,95.0),(440,662,120),(565,680,125),(664,590,105),(512,580,145)] {
    let puff = NSBezierPath(ovalIn: CGRect(x: x-radius, y: y-radius*0.8, width: radius*2, height: radius*1.6))
    NSGradient(starting: amber, ending: deep)!.draw(in: puff, angle: -70)
}
let nucleus = NSBezierPath(ovalIn: CGRect(x: 493, y: 490, width: 38, height: 38))
NSColor(calibratedRed: 0.91, green: 0.95, blue: 0.97, alpha: 1).setFill(); nucleus.fill()
let orbit = NSBezierPath(ovalIn: CGRect(x: 380, y: 442, width: 264, height: 134))
orbit.lineWidth = 3
NSColor(calibratedRed: 0.34, green: 0.93, blue: 0.96, alpha: 0.9).setStroke(); orbit.stroke()
NSGraphicsContext.restoreGraphicsState()
let png = bitmap.representation(using: .png, properties: [:])!
try png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
