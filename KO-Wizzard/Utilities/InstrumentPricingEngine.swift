//
//  InstrumentPricingEngine.swift
//  KO-Wizzard
//

import Foundation

struct InstrumentPricingEngine {

	enum PricingError: Error {
		case invalidInput
		case missingData
		case ratioZero
	}

	struct PricingResult {
		let value: Double?
		let error: PricingError?
	}

	struct UnderlyingResult {
		let value: Double?
		let error: PricingError?
	}

	struct CalculationDisplayResult {
		let underlying: String
		let certificate: String
	}

	static func priceFromUnderlying(
		instrument: Instrument,
		underlyingPrice: Double
	) -> PricingResult {
		guard underlyingPrice.isFinite else {
			return PricingResult(value: nil, error: .invalidInput)
		}

		guard instrument.direction != .none else {
			return PricingResult(value: nil, error: .missingData)
		}

		guard let basispreis = Instrument.parseNumber(instrument.basispreis) else {
			return PricingResult(value: nil, error: .missingData)
		}

		guard let ratio = ratioMultiplier(from: instrument.bezugsverhaeltnis) else {
			return PricingResult(value: nil, error: .missingData)
		}

		if abs(ratio) < 1e-12 {
			return PricingResult(value: nil, error: .ratioZero)
		}

		let aufgeld = Instrument.parseNumber(instrument.aufgeld) ?? 0
		let price: Double

		switch instrument.direction {
			case .long:
				price = (underlyingPrice - basispreis) * ratio + aufgeld
			case .short:
				price = (basispreis - underlyingPrice) * ratio + aufgeld
			case .none:
				return PricingResult(value: nil, error: .missingData)
		}

		return PricingResult(value: price, error: nil)
	}

	static func calculateFromUnderlying(
		raw: String,
		instrument: Instrument
	) -> CalculationDisplayResult {
		guard let underlying = Instrument.parseNumber(raw) else {
			return CalculationDisplayResult(underlying: "—", certificate: "—")
		}

		let result = priceFromUnderlying(
			instrument: instrument,
			underlyingPrice: underlying
		)

		let certificate: String
		if let value = result.value {
			certificate = Instrument.compact(value)
		} else {
			certificate = "—"
		}

		return CalculationDisplayResult(underlying: raw, certificate: certificate)
	}

	static func underlyingFromPrice(
		instrument: Instrument,
		certificatePrice: Double
	) -> UnderlyingResult {
		guard certificatePrice.isFinite else {
			return UnderlyingResult(value: nil, error: .invalidInput)
		}

		guard instrument.direction != .none else {
			return UnderlyingResult(value: nil, error: .missingData)
		}

		guard let basispreis = Instrument.parseNumber(instrument.basispreis) else {
			return UnderlyingResult(value: nil, error: .missingData)
		}

		guard let ratio = ratioMultiplier(from: instrument.bezugsverhaeltnis) else {
			return UnderlyingResult(value: nil, error: .missingData)
		}

		if abs(ratio) < 1e-12 {
			return UnderlyingResult(value: nil, error: .ratioZero)
		}

		let aufgeld = Instrument.parseNumber(instrument.aufgeld) ?? 0
		let underlying: Double

		switch instrument.direction {
			case .long:
				underlying = basispreis + (certificatePrice - aufgeld) / ratio
			case .short:
				underlying = basispreis - (certificatePrice - aufgeld) / ratio
			case .none:
				return UnderlyingResult(value: nil, error: .missingData)
		}

		return UnderlyingResult(value: underlying, error: nil)
	}

	static func calculateFromCertificate(
		raw: String,
		instrument: Instrument
	) -> CalculationDisplayResult {
		guard let certificate = Instrument.parseNumber(raw) else {
			return CalculationDisplayResult(underlying: "—", certificate: "—")
		}

		let result = underlyingFromPrice(
			instrument: instrument,
			certificatePrice: certificate
		)

		let underlying: String
		if let value = result.value {
			underlying = Instrument.compact(value)
		} else {
			underlying = "—"
		}

		return CalculationDisplayResult(underlying: underlying, certificate: raw)
	}

	private static func ratioMultiplier(from raw: String) -> Double? {
		let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
		if trimmed.isEmpty { return nil }

		let compact = trimmed.replacingOccurrences(of: " ", with: "")
		if compact.contains(":") {
			let parts = compact.split(separator: ":")
			if parts.count == 2,
			   let right = Instrument.parseNumber(String(parts[1])) {
				return right == 0 ? 0 : 1.0 / right
			}
			return nil
		}

		guard let n = Instrument.parseNumber(compact) else { return nil }
		return n == 0 ? 0 : 1.0 / n
	}
}
