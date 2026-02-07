//
//  ParticleEmitter.swift
//  YouHQ
//
//  Created by Ryan Token on 2/6/26.
//

import SwiftUI

struct ParticleEmitter: View {
	var images: [String]
	var particleCount: Int

	var creationPoint = UnitPoint.center
	var creationRange = CGSize.zero

	var colors = [Color.white]
	var blendMode = BlendMode.normal

	var angle = Angle.zero
	var angleRange = Angle.zero

	var opacity = 1.0
	var opacityRange = 0.0
	var opacitySpeed = 0.0

	var rotation = Angle.zero
	var rotationRange = Angle.zero
	var rotationSpeed = Angle.zero

	var scale: CGFloat = 1
	var scaleRange: CGFloat = 0
	var scaleSpeed: CGFloat = 0

	var speed = 50.0
	var speedRange = 0.0

	var animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)
	var animationDelayThreshold = 0.0

	var body: some View {
		GeometryReader { geo in
			ZStack {
				ForEach(0..<particleCount, id: \.self) { _ in
					ParticleView(
						image: Image(images.randomElement()!),
						position: position(in: geo),
						opacity: makeOpacity(),
						rotation: makeRotation(),
						scale: makeScale(),
						animation: animation,
						animationDelay: Double.random(in: 0...animationDelayThreshold)
					)
					.colorMultiply(colors.randomElement() ?? .white)
					.blendMode(blendMode)
				}
			}
		}
	}

	private func position(in proxy: GeometryProxy) -> ParticleState<CGPoint> {
		let halfCreationRangeWidth = creationRange.width / 2
		let halfCreationRangeHeight = creationRange.height / 2

		let creationOffsetX = CGFloat.random(in: -halfCreationRangeWidth...halfCreationRangeWidth)
		let creationOffsetY = CGFloat.random(in: -halfCreationRangeHeight...halfCreationRangeHeight)

		let startX = Double(proxy.size.width * (creationPoint.x + creationOffsetX))
		let startY = Double(proxy.size.height * (creationPoint.y + creationOffsetY))
		let start = CGPoint(x: startX, y: startY)

		let halfSpeedRange = speedRange / 2
		let actualSpeed = speed + Double.random(in: -halfSpeedRange...halfSpeedRange)

		let halfAngleRange = angleRange.radians / 2
		let actualDirection = angle.radians + Double.random(in: -halfAngleRange...halfAngleRange)

		let finalX = cos(actualDirection - .pi / 2) * actualSpeed
		let finalY = sin(actualDirection - .pi / 2) * actualSpeed
		let end = CGPoint(x: startX + finalX, y: startY + finalY)

		return ParticleState(start, end)
	}

	private func makeOpacity() -> ParticleState<Double> {
		let halfOpacityRange = opacityRange / 2
		let randomOpacity = Double.random(in: -halfOpacityRange...halfOpacityRange)
		return ParticleState(opacity + randomOpacity, opacity + opacitySpeed + randomOpacity)
	}

	private func makeScale() -> ParticleState<CGFloat> {
		let halfScaleRange = scaleRange / 2
		let randomScale = CGFloat.random(in: -halfScaleRange...halfScaleRange)
		return ParticleState(scale + randomScale, scale + scaleSpeed + randomScale)
	}

	private func makeRotation() -> ParticleState<Angle> {
		let halfRotationRange = (rotationRange / 2).radians
		let randomRotation = Double.random(in: -halfRotationRange...halfRotationRange)
		let randomRotationAngle = Angle(radians: randomRotation)
		return ParticleState(rotation + randomRotationAngle, rotation + rotationSpeed + randomRotationAngle)
	}

	private struct ParticleView: View {
		@State private var isActive = false

		let image: Image
		let position: ParticleState<CGPoint>
		let opacity: ParticleState<Double>
		let rotation: ParticleState<Angle>
		let scale: ParticleState<CGFloat>
		let animation: Animation
		let animationDelay: Double

		var body: some View {
			image
				.opacity(isActive ? opacity.end : opacity.start)
				.scaleEffect(isActive ? scale.end : scale.start)
				.rotationEffect(isActive ? rotation.end : rotation.start)
				.position(isActive ? position.end : position.start)
				.animation(animation.delay(animationDelay), value: isActive)
				.onAppear{ isActive = true }
		}
	}

	private struct ParticleState<T> {
		var start: T
		var end: T

		init(_ start: T, _ end: T) {
			self.start = start
			self.end = end
		}
	}
}

#Preview {
	ParticleEmitter(images: ["confetti"], particleCount: 200)
}
