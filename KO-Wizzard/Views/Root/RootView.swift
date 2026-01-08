import SwiftUI
import Foundation
import UserNotifications

struct RootView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		if appState.isLandingVisible {
			LandingView()
		} else {
			WorkspaceView()
		}
	}
}

#Preview {
	RootView()
		.environmentObject(AppStateEngine())
}
