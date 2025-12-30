//
//  AppEntryPoint.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SwiftUI

struct AppEntryPoint: View {
	var body: some View {
		TabView {
			Tab("Homes", systemImage: "house") {
				NavigationStack {
					ResidenceScreen()
				}
			}
			Tab("Vehicles", systemImage: "car.2") {
				NavigationStack {
					VehicleScreen()
				}
			}
			Tab("Money", systemImage: "dollarsign") {
				NavigationStack {
					MoneyScreen()
				}
			}
			Tab("Media", systemImage: "desktopcomputer.and.macbook") {
				NavigationStack {
					MediaScreen()
				}
			}
			Tab("Career", systemImage: "briefcase") {
				NavigationStack {
					CareerScreen()
				}
			}
		}
	}
}

#Preview {
	AppEntryPoint()
}
