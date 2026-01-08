//
//  WorkspaceBodyView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 23.11.25.


import SwiftUI

struct WorkspaceBodyView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		HStack(spacing: 0) {

				// Sidebar links
			SidebarView()
				.frame(width: 300)

				// Content rechts
			ContentRouterView()
		}
	}
}
