//
//  MusicVisualizer.swift
//  boringNotch
//
//  Created by Harsh Vardhan  Goswami  on 02/08/24.
//
import AppKit
import Cocoa
import SwiftUI

class AudioSpectrum: NSView {
    private let barWidth: CGFloat = 2
    private let barCount = 4
    private let barSpacing: CGFloat = 2
    private let totalHeight: CGFloat = 14
    private var barLayers: [CAShapeLayer] = []
    private var isPlaying: Bool = true
    private var animationTimer: Timer?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        setupBars()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        setupBars()
    }

    private func setupBars() {
        let totalWidth = CGFloat(barCount) * (barWidth + barSpacing)
        frame.size = CGSize(width: totalWidth, height: totalHeight)

        for i in 0 ..< barCount {
            let xPosition = CGFloat(i) * (barWidth + barSpacing)
            let barLayer = CAShapeLayer()
            barLayer.frame = CGRect(x: xPosition, y: 0, width: barWidth, height: totalHeight)
            barLayer.fillColor = NSColor.white.cgColor
            barLayer.path = makeBarPath(scale: 0.35)
            barLayers.append(barLayer)
            layer?.addSublayer(barLayer)
        }
    }

    private func makeBarPath(scale: CGFloat) -> CGPath {
        let height = totalHeight * scale
        let rect = CGRect(
            x: 0,
            y: (totalHeight - height) / 2,
            width: barWidth,
            height: height
        )
        return NSBezierPath(
            roundedRect: rect,
            xRadius: barWidth / 2,
            yRadius: barWidth / 2
        ).cgPath
    }
    
    private func startAnimating() {
        guard animationTimer == nil else { return }
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.updateBars()
        }
    }
    
    private func stopAnimating() {
        animationTimer?.invalidate()
        animationTimer = nil
        resetBars()
    }
    
    private func updateBars() {
        for barLayer in barLayers {
            let targetScale = CGFloat.random(in: 0.35 ... 1.0)
            let targetPath = makeBarPath(scale: targetScale)
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = barLayer.presentation()?.path ?? barLayer.path
            animation.toValue = targetPath
            animation.duration = 0.3
            if #available(macOS 13.0, *) {
                animation.preferredFrameRateRange = CAFrameRateRange(minimum: 24, maximum: 24, preferred: 24)
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            barLayer.path = targetPath
            CATransaction.commit()
            barLayer.add(animation, forKey: "path")
        }
    }
    
    private func resetBars() {
        for barLayer in barLayers {
            barLayer.removeAllAnimations()
            barLayer.path = makeBarPath(scale: 0.35)
        }
    }
    
    func setPlaying(_ playing: Bool) {
        isPlaying = playing
        if isPlaying {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
}

struct AudioSpectrumView: NSViewRepresentable {
    @Binding var isPlaying: Bool
    
    func makeNSView(context: Context) -> AudioSpectrum {
        let spectrum = AudioSpectrum()
        spectrum.setPlaying(isPlaying)
        return spectrum
    }
    
    func updateNSView(_ nsView: AudioSpectrum, context: Context) {
        nsView.setPlaying(isPlaying)
    }
}

#Preview {
    AudioSpectrumView(isPlaying: .constant(true))
        .frame(width: 16, height: 20)
        .padding()
}
