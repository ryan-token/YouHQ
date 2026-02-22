//
//  AppOnboardingFlow.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import Combine
import SQLiteData
import SwiftUI

struct AppOnboardingFlow: View {
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.dismiss) private var dismiss
	@Environment(PaywallManager.self) private var paywallManager

	@State private var vm = ViewModel()

	let fromSettings: Bool
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let timeOnEachTab = 4
	let lastAutoAdvanceTab = 5 // Stop auto-advancing after OnboardingEndView

	init(fromSettings: Bool = false) {
		self.fromSettings = fromSettings
	}

	var body: some View {
		NavigationStack(path: $vm.navigationPath) {
			VStack(spacing: 8) {
				if vm.currentTab != vm.paywallTab {
					VStack(spacing: 0) {
						ScalableImage("AppIcon-1024", height: 90)

						HQText("YouHQ")
							.font(.largeTitle)
							.fontWeight(.black)

						HQText("Your life, organized.")
							.font(.title)
							.fontWeight(.semibold)
					}
					.padding(.top)
					#if !os(macOS)
						.if(UIDevice.current.userInterfaceIdiom == .pad) {
							$0.padding(.top, 40)
						}
					#endif
				}

				TabView(selection: $vm.currentTab) {
					ForEach(0..<5) { idx in
						VStack {
							ScalableImage(
								colorScheme == .light ? screenshots[idx].imageNameLight : screenshots[idx].imageNameDark,
								height: nil
							)
							.frame(maxHeight: 525)

							HQText(screenshots[idx].title)
								.font(.title2)
								.fontWeight(.bold)

							HQText(screenshots[idx].description)
								.font(.headline)
								.fontWeight(.medium)
						}
						.padding(.horizontal, 8)
						.padding(.bottom, 40)
						.tag(idx)
					}

					OnboardingEndView {
						withAnimation {
							vm.currentTab = 6
						}
					}
					.tag(5)

					OnboardingProfileCreationView {
						withAnimation {
							vm.navigateAfterProfileCreation(hasUnlockedPremium: paywallManager.hasUnlockedPremium)
						}
					}
					.tag(6)

					#if os(macOS)
						ScrollView {
							Paywall(fromOnboarding: true, shouldShowSkipButton: true, shouldShowDismissButton: false) {
								vm.navigationPath.append("congratulations")
							}
						}
						.tag(vm.paywallTab)
						.disabled(!vm.hasAnyProfile)
					#else
						Paywall(fromOnboarding: true, shouldShowSkipButton: true, shouldShowDismissButton: false) {
							vm.navigationPath.append("congratulations")
						}
						.tag(vm.paywallTab)
					#endif
				}
				#if !os(macOS)
					.tabViewStyle(.page(indexDisplayMode: .never))
				#else
					.tabViewStyle(.grouped)
				#endif
				.opacity(vm.isStartingOnboarding ? 0 : 1)
			}
			.background(backgroundGradient)
			.navigationDestination(for: String.self) { destination in
				if destination == "congratulations" {
					OnboardingCongratulationsView()
				}
			}
			.onChange(of: vm.currentTab) { oldValue, newValue in
				Task {
					await vm.handleTabChange(oldValue: oldValue, newValue: newValue, hasUnlockedPremium: paywallManager.hasUnlockedPremium)
				}
			}
			.onReceive(timer) { _ in
				vm.handleTimerTick(timeOnEachTab: timeOnEachTab, lastAutoAdvanceTab: lastAutoAdvanceTab)
			}
		}
		#if !os(macOS)
			.toolbar(.hidden, for: .navigationBar)
			.overlay(alignment: .topLeading) {
				if fromSettings && UIDevice.current.userInterfaceIdiom == .phone {
					backButton
					.padding()
				}
			}
		#endif
		.alert("Profile Required", isPresented: $vm.showProfileRequiredAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("You must create a profile before proceeding.")
		}
		.task {
			await paywallManager.refreshEntitlementsIfNeeded()
			await vm.checkForProfile()
		}
		.onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { _ in
			Task {
				await vm.checkForProfile()
			}
		}
	}

	@ViewBuilder
	private var backgroundGradient: some View {
		if vm.currentTab == vm.paywallTab {
			PaywallGradient()
		} else {
			LinearGradient(colors: [.clear, .clear], startPoint: .top, endPoint: .bottom)
		}
	}

	private var backButton: some View {
		Button {
			dismiss()
		} label: {
			Image(systemName: "chevron.left")
				.font(.title2.weight(.medium))
		}
		#if !os(visionOS)
			.buttonStyle(.glass)
		#endif
	}

	private let screenshots: [ScreenshotConfig] = [
		.init(
			title: "Home",
			description: "Track utilities, paint colors, maintenance, & more",
			imageNameLight: "onboarding.home.light",
			imageNameDark: "onboarding.home.dark"
		),
		.init(
			title: "Vehicles",
			description: "Track insurance, paint colors, & maintenance",
			imageNameLight: "onboarding.vehicles.light",
			imageNameDark: "onboarding.vehicles.dark"
		),
		.init(
			title: "Money",
			description: "Track banks, investment accounts, & HSA/FSAs",
			imageNameLight: "onboarding.money.light",
			imageNameDark: "onboarding.money.dark"
		),
		.init(
			title: "Media",
			description: "Track service providers, subscriptions, & devices",
			imageNameLight: "onboarding.media.light",
			imageNameDark: "onboarding.media.dark"
		),
		.init(
			title: "Career",
			description: "Track jobs & salary history over time",
			imageNameLight: "onboarding.career.light",
			imageNameDark: "onboarding.career.dark"
		)
	]

	private struct ScreenshotConfig {
		let title: String
		let description: String
		let imageNameLight: String
		let imageNameDark: String
	}
}

#Preview {
	struct AppOnboardingPreview: View {
		@State private var paywallManager = PaywallManager()

		var body: some View {
			NavigationStack {
				AppOnboardingFlow()
					.environment(paywallManager)
			}
		}
	}
	return AppOnboardingPreview()
}
