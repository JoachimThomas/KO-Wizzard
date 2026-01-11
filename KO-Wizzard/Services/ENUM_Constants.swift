//
//  ENUM_Constants.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//
import Foundation

	// MARK: - AssetClass

enum AssetClass: String, CaseIterable, Identifiable, Codable {

	case index     = "index"
	case fx        = "fx"
	case aktie     = "aktie"
	case rohstoff  = "rohstoff"
	case crypto    = "crypto"
	case igBarrier = "igbarrier"
	case none      = ""


}

	// MARK: - Subgroup (Underlying-Typen für AssetClass)

enum Subgroup: String, CaseIterable, Identifiable,Codable {
	case dax
	case dow
	case sp500
	case nasdaq
	case russell2000

	case eurUsd
	case usdJpy
	case gbpUsd

	case oil
	case gas
	case gold

	case bitcoinUsd
	case ethereumUsd

}

	// MARK: - Direction

enum Direction: String, CaseIterable, Identifiable, Codable {
	case long  = "long"
	case short = "short"
	case none = ""


}

	// MARK: - Emittent

enum Emittent: String, CaseIterable, Identifiable, Codable {
	case bnp
	case citi
	case dzbank
	case goldman
	case hsbc
	case ing
	case jpmorgan
	case societegenerale
	case ubs
	case vontobel
	case igMarkets
	case none

}

	// MARK: - Bezugsverhältnis (Ratio)

enum RatioOption: String, CaseIterable, Identifiable, Codable {
	case none = "–"
	case oneToOne    = "1 : 1"
	case oneToTen    = "1 : 10"
	case oneToHundred = "1 : 100"
	case oneToThousand = "1 : 1 000"
	case custom      = "Individuell…"

}
