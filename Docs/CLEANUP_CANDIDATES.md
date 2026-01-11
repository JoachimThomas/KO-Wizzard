## Kandidaten zum Entfernen (Stand: Analyse)

### Runde 1 – entfernt (sehr sichere Treffer, keine Referenzen gefunden)
- `KO-Wizzard/Views/Content/Tabs/ImportBasicsSheet.swift`
  - Grund: Kein Verweis auf `ImportBasicsSheet` im Repo (`rg "ImportBasicsSheet"` nur Definition).
  - Xcodeproj: Keine Referenz in `KO-Wizzard.xcodeproj/project.pbxproj`.
- `KO-Wizzard/Views/Content/Tabs/TradeContentView.swift`
  - Grund: Kein Verweis auf `TradeContentView` (`rg "TradeContentView"` nur Definition).
  - Router: `ContentRouterView` nutzt nur `InstrumentCreateView`, `InstrumentDetailView`, `InstrumentCalcView`.
  - Xcodeproj: Keine Referenz in `KO-Wizzard.xcodeproj/project.pbxproj`.
- `KO-Wizzard/Views/Content/Tabs/ReportsView.swift`
  - Grund: Kein Verweis auf `ReportsView` außerhalb der Preview (`rg "ReportsView"`).
  - Router: Nicht in `ContentRouterView`.
  - Xcodeproj: Keine Referenz in `KO-Wizzard.xcodeproj/project.pbxproj`.
- `KO-Wizzard/Views/Content/Tabs/ReportView.swift`
  - Grund: Nur von `ReportsView` genutzt, sonst keine Referenzen.
  - Wenn `ReportsView` entfernt wird, ist diese Datei ebenfalls verwaist.

### Runde 2 – entfernt (nach Bestätigung der Nicht-Nutzung)
- `KO-Wizzard/Services/ENUM_Constants.swift` → `Broker`
  - Grund: `Broker` wird nur in `TradeContentView` erwähnt (sonst keine Treffer).
  - Wenn `TradeContentView` entfernt ist, wird `Broker` ungenutzt.
- `KO-Wizzard/Services/ENUM_Constants.swift` → `AssetClass.subgroups(for:)`
  - Grund: Keine Treffer für `subgroups(for:)` (`rg "subgroups\\(for"`).
  - Es gibt stattdessen `subgroupsTyped(for:)`, die genutzt wird.
- `KO-Wizzard/Models/Instrument.swift` → `koDistancePercent(underlying:)`
  - Grund: Keine Treffer für `koDistancePercent` (`rg "koDistancePercent"`).
- `KO-Wizzard/Models/Instrument.swift` → `suggestedSidebarTitle()`
  - Grund: Keine Treffer für `suggestedSidebarTitle` (`rg "suggestedSidebarTitle"`).
- `KO-Wizzard/Services/InstrumentStore.swift` → `isValid(_:)` + `isValidDecimalString`
  - Grund: Keine Treffer für `isValid(` außerhalb der Definition.
- `KO-Wizzard/Services/InstrumentStore.swift` → `delete(at:)`, `move(from:to:)`
  - Grund: Keine Treffer für `delete(at` / `move(from`.
- `KO-Wizzard/Models/AppStateEngine.swift` → `RootTab`, `selectedTab`, `selectTab(_:)`, `showInstrumentList()`
  - Grund: `selectedTab` wird nur gesetzt, aber nirgends gelesen; `selectTab`/`showInstrumentList` ohne Callsite.
  - Achtung: Wird an mehreren Stellen gesetzt (z. B. `LandingView`), daher vorsichtiger Kandidat.
