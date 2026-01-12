//
//  LandingView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//
import SwiftUI

struct LandingView: View {

	@EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var theme
	@State private var isCreateHovered: Bool = false
	@State private var isShowHovered: Bool = false
	@State private var isCalcHovered: Bool = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear // Dient als Anker für die Fenstergröße
                .background(
                    Image("Chart")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
                //.clipped() // Schneidet Überhänge ab

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.55),
                            Color.black.opacity(0.15),
                            Color.black.opacity(0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                glossyLandingButton(
                    icon: "doc.badge.plus",
                    isHovered: isCreateHovered
                ) {
                    appState.enterCreateMode()
                }
                .onHover { hovering in
                    isCreateHovered = hovering
                }

                glossyLandingButton(
                    icon: "eye",
                    isHovered: isShowHovered
                ) {
                    appState.enterShowAndChangeMode()
                }
                .onHover { hovering in
                    isShowHovered = hovering
                }

				glossyLandingButton(
					icon: "function",
					isHovered: isCalcHovered
				) {
					appState.navigation.workspaceMode = .instrumentCalculation
					appState.navigation.isLandingVisible = false
				}
                .onHover { hovering in
                    isCalcHovered = hovering
                }

                Spacer()
            }
            .padding(.top, 70)
            .padding(.leading, 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

	private func glossyLandingButton(
		icon: String,
		isHovered: Bool,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			ZStack {
				Circle()
					.fill(theme.gradients.landingButton(theme.colors))
					.shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)

				Circle()
					.stroke(Color.white.opacity(0.18), lineWidth: 1)

				Circle()
					.stroke(theme.colors.glowRing.opacity(isHovered ? 0.7 : 0), lineWidth: 2)
					.blur(radius: isHovered ? 1 : 2)
					.animation(.easeInOut(duration: 0.14), value: isHovered)

				Circle()
					.fill(
						RadialGradient(
							colors: [Color.white.opacity(0.22), Color.clear],
							center: .topLeading,
							startRadius: 2,
							endRadius: 30
						)
					)
					.blendMode(.screen)

				Circle()
					.stroke(
						LinearGradient(
							colors: [Color.white.opacity(0.22), Color.clear],
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						),
						lineWidth: 2
					)
					.blur(radius: 0.5)

				Image(systemName: icon)
					.font(.system(size: 27, weight: .semibold))
			}
			.frame(width: 64, height: 64)
			.shadow(
				color: Color.black.opacity(isHovered ? 0.35 : 0.22),
				radius: isHovered ? 12 : 8,
				x: 0,
				y: isHovered ? 8 : 6
			)
			.shadow(
				color: theme.colors.glowRing.opacity(isHovered ? 0.25 : 0.12),
				radius: isHovered ? 10 : 6,
				x: 0,
				y: 0
			)
			.offset(y: isHovered ? -3 : 0)
			.animation(theme.effects.hoverAnimation, value: isHovered)
		}
		.buttonStyle(PressableGlossyStyle())
		.focusable(false)
		.focusEffectDisabled(true)
	}
}

private struct PressableGlossyStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.96 : 1)
			.foregroundColor(configuration.isPressed ? Color.white.opacity(0.9) : .white)
			.animation(.easeInOut(duration: 0.13), value: configuration.isPressed)
	}
}

#Preview {
	LandingView()
		.environmentObject(AppStateEngine())
}
