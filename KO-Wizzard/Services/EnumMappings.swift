//
//  EnumMappings.swift
//  KO-Wizzard
//

import Foundation

// MARK: - AssetClass

extension AssetClass {
	static func subgroupsTyped(for asset: AssetClass) -> [Subgroup] {
		switch asset {
			case .index:
				return [.dax, .dow, .sp500, .nasdaq, .russell2000]
			case .fx:
				return [.eurUsd, .usdJpy, .gbpUsd]
			case .aktie:
				return []
			case .rohstoff:
				return [.oil, .gas, .gold]
			case .crypto:
				return [.bitcoinUsd, .ethereumUsd]
			case .igBarrier:
				// IG kann Index + FX + Rohstoff
				return [.dax, .dow, .sp500, .nasdaq, .eurUsd, .gold]
			case .none:
				return []
		}
	}
}

// MARK: - Subgroup

extension Subgroup {
	var assetClass: AssetClass {
		switch self {
			case .dax, .dow, .sp500, .nasdaq, .russell2000:
				return .index
			case .eurUsd, .usdJpy, .gbpUsd:
				return .fx
			case .oil, .gas, .gold:
				return .rohstoff
			case .bitcoinUsd, .ethereumUsd:
				return .crypto
		}
	}

	static func from(displayName: String) -> Subgroup? {
		let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return nil }

		return Self.allCases.first {
			$0.displayName.compare(trimmed,
								   options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
		}
	}
}

// MARK: - RatioOption

extension RatioOption {
	var numericValue: String {
		switch self {
			case .none:          return ""
			case .oneToOne:      return "1"
			case .oneToTen:      return "10"
			case .oneToHundred:  return "100"
			case .oneToThousand: return "1000"
			case .custom:        return "custom"
		}
	}
}
