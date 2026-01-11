//
//  EnumDisplayNames.swift
//  KO-Wizzard
//

import Foundation

// MARK: - Identity

extension AssetClass {
	var id: String { rawValue }
}

extension Subgroup {
	var id: String { rawValue }
}

extension Direction {
	var id: String { rawValue }
}

extension Emittent {
	var id: String { rawValue }
}

extension RatioOption {
	var id: String { rawValue }
}

// MARK: - Display Names

extension AssetClass {
	var displayName: String {
		switch self {
			case .index:     return "Index"
			case .fx:        return "FX"
			case .aktie:     return "Aktie"
			case .rohstoff:  return "Rohstoff"
			case .crypto:    return "Crypto"
			case .igBarrier: return "IG-Barrier"
			case .none:      return ""
		}
	}
}

extension Subgroup {
	var displayName: String {
		switch self {
			case .dax:          return "DAX"
			case .dow:          return "Dow"
			case .sp500:        return "S&P 500"
			case .nasdaq:       return "Nasdaq"
			case .russell2000:  return "Russell 2000"

			case .eurUsd:       return "EUR/USD"
			case .usdJpy:       return "USD/JPY"
			case .gbpUsd:       return "GBP/USD"

			case .oil:          return "Öl"
			case .gas:          return "Gas"
			case .gold:         return "Gold"

			case .bitcoinUsd:   return "Bitcoin/USD"
			case .ethereumUsd:  return "Ethereum/USD"
		}
	}
}

extension Direction {
	var displayName: String {
		switch self {
			case .long:  return "Long"
			case .short: return "Short"
			case .none:  return ""
		}
	}
}

extension Emittent {
	var displayName: String {
		switch self {
			case .bnp:             return "BNP Paribas"
			case .citi:            return "Citi"
			case .dzbank:          return "DZ Bank"
			case .goldman:         return "Goldman Sachs"
			case .hsbc:            return "HSBC"
			case .ing:             return "ING Markets"
			case .jpmorgan:        return "JP Morgan"
			case .societegenerale: return "Société Générale"
			case .ubs:             return "UBS"
			case .vontobel:        return "Vontobel"
			case .igMarkets:       return "IG-Markets"
			case .none:            return ""
		}
	}
}

extension RatioOption {
	var displayName: String { rawValue }
}
