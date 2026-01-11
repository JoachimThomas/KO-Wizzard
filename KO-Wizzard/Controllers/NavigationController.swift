//
//  NavigationController.swift
//  KO-Wizzard
//

import Foundation
import Combine

final class NavigationController: ObservableObject {

	enum WorkspaceMode: Hashable {
		case instrumentsCreate
		case instrumentsShowAndChange
		case instrumentCalculation
	}

	@Published var workspaceMode: WorkspaceMode = .instrumentsShowAndChange
	@Published var isLandingVisible: Bool = true
}
