# Projekt-Anchor: KO-Wizzard

Stand: 2026-01-11

## Zweck
Desktop-App (SwiftUI) zum Anlegen, Anzeigen und Berechnen von KO-/Turbo-/Barrier-Instrumenten. Fokus liegt auf Instrumenten-Stammdaten, einer Wizard-Erfassung und einer einfachen Berechnung (Underlying ↔ Zertifikatspreis).

## Architektur (MVC-orientiert)
- **Models**: Domänenmodelle wie `Instrument`.
- **Controllers**: Steuerung und State-Logik in separaten Controllern, orchestriert durch `AppStateEngine`.
- **Views**: SwiftUI-Ansichten, die ausschließlich über `AppStateEngine` arbeiten.
- **Services/Utilities**: Persistenz, Parsing, Berechnung, Input-Sanitizing.

## Zentrale Komponenten
- **AppStateEngine** (`KO-Wizzard/Models/AppStateEngine.swift`)
  - Orchestrator für Controller und Store.
  - Bündelt Navigation, Draft-Flow, Listenlogik und Collapse-State.

- **Controller** (`KO-Wizzard/Controllers/`)
  - `NavigationController`: `workspaceMode`, Landing-Sichtbarkeit.
  - `InstrumentDraftController`: Draft-Instrument, Wizard-Schritte, Edit-Flow.
  - `InstrumentListController`: Filter/Suche/Sortierung/Grouping der Instrumente.
  - `SidebarCollapseController`: Collapse-Logik für AssetClass/Subgroup/Direction.

- **Model**
  - `Instrument` (`KO-Wizzard/Models/Instrument.swift`): Stammdaten, Parsing/Formatting, berechnete Werte.

- **Store**
  - `InstrumentStore` (`KO-Wizzard/Services/InstrumentStore.swift`): In-Memory + JSON-Persistenz im Dokumente-Ordner, Auto-Save.

- **Berechnung**
  - `InstrumentPricingEngine` (`KO-Wizzard/Utilities/InstrumentPricingEngine.swift`): Preis- und Underlying-Rechnung.

- **Import**
  - `BasicsImportParser` (`KO-Wizzard/Utilities/BasicsImportParser.swift`): extrahiert Basisdaten aus Freitext.

## UI-Struktur
- `RootView` zeigt Landing oder Workspace.
- `WorkspaceView` enthält Toolbar + Sidebar + Content.
- `ContentRouterView` routet nach `workspaceMode`.
- Sidebar ist gruppiert nach AssetClass → Subgroup → Direction.
- Create-Flow als Wizard mit Sheets (`ValueInputSheet`, `SubgroupPickerSheet`).

## Navigationsmodi
- `instrumentsCreate`: Wizard-Flow für neue Instrumente.
- `instrumentsShowAndChange`: Detailansicht ausgewählter Instrumente.
- `instrumentCalculation`: Berechnung anhand des selektierten Instruments.

## Persistenz & Auswahlverhalten
- JSON-File: `KO_Wizard_Instruments.json` im Dokumente-Ordner.
- Beim Start wird das zuletzt geänderte Instrument selektiert.
- Nur dessen AssetClass/Subgroup/Direction ist initial aufgeklappt.

## Dateien & Ordner (Kurzüberblick)
- `KO-Wizzard/Models/` – Domänenmodelle + AppStateEngine.
- `KO-Wizzard/Controllers/` – Navigation/Draft/List/Collapse.
- `KO-Wizzard/Services/` – Store + Enum-Logik.
- `KO-Wizzard/Utilities/` – Parser, Pricing, Sanitizer.
- `KO-Wizzard/Views/` – SwiftUI UI.
- `Docs/PROJECT_ANCHOR.md` – dieser Anker.

## Build
- Xcode Scheme: `KO-Wizzard`.
- Debug-Check: `xcodebuild -project KO-Wizzard.xcodeproj -scheme KO-Wizzard -configuration Debug -destination 'platform=macOS' build`.

---
Stand: 2026-01-11
Branch: refactor/view-cleanup
Commit: 600e0f1c74d3acdc30bef666a7da7aa24edeb7e9
Kurzbeschreibung: Views verschlankt (Logik in Controller/Utilities), Sidebar-Selection-Style zentralisiert, Non-UI-Verbesserungen (Sanitizer/Autosave/Decoder-Logging/Formatter-Caching), Utilities nach Domänen (Parsing/Calculation/Draft) organisiert.
