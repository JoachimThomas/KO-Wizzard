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

#### ✅ Milestone Summary — 2026-01-11 19:55 (Local)
- **Branch:** feature/style-system
- **Commit:** 3bbff54
- **Tag (optional):** —
- **Status:** Build green / App runs (not verified) / git status clean

##### Scope (was war das Ziel?)
- Zentralisierte UI-Tokens und ein konsistentes Light/Dark-Theme schaffen sowie die Toolbar/Sidebar/Content-Ansichten visuell vereinheitlichen und stabilisieren.

##### Changes (was wurde geändert?)
- Zentrales Theme-System eingefuehrt (Colors/Fonts/Metrics/Gradients/Effects) mit System/Light/Dark-Aufloesung.
- Reusable Style-Modifiers fuer Cards, Toolbar-Tabs/Icon-Buttons und Titlebar/Footer-Styles aufgebaut.
- System-Mode korrekt an `colorScheme` gekoppelt, um falsche Farben im Systemmodus zu vermeiden.
- Darkmode-Chrome (Titlebar/Footer/Buttons) auf Orange ausgerichtet, Glow-Ring in Darkmode Blau, Hover/Pressed staerker.
- Toolbar-Position dynamisch unter der Titlebar stabilisiert; feiner Fensterrahmen hinzugefuegt.
- Sidebar-Selektion auf Suchfeld-Farbton gesetzt; Sidebar mit card-aehnlichem Rahmen versehen.
- Tab-Content vereinheitlicht: Title-Cards oben, Detail/Berechnung in eine Haupt-Card konsolidiert.
- Import-Aktion in Create-Flow inline zu Assetklasse/Subgroup gezogen, Tooltip erklaert Komplett-Import.
- Copy-to-Clipboard-Icon fuer berechnete Werte in der Berechnung sichtbar (bei vorhandenem Wert).

##### Files touched (Whitelist / Ueberblick)
- Docs/AI_MODE.md
- Docs/CLEANUP_CANDIDATES.md
- KO-Wizzard/KO_WizzardApp.swift
- KO-Wizzard/Style/AppStyleModifiers.swift
- KO-Wizzard/Style/AppTheme.swift
- KO-Wizzard/Views/Content/ContentRouterView.swift
- KO-Wizzard/Views/Content/InstrumentCreateComponents.swift
- KO-Wizzard/Views/Content/InstrumentCreateFlowView.swift
- KO-Wizzard/Views/Content/InstrumentCreateView.swift
- KO-Wizzard/Views/Content/SubgroupPickerSheet.swift
- KO-Wizzard/Views/Content/Tabs/InstrumentCalcView.swift
- KO-Wizzard/Views/Content/Tabs/InstrumentDetailView.swift
- KO-Wizzard/Views/Content/ValueInputSheet.swift
- KO-Wizzard/Views/Content/WorkspaceBodyView.swift
- KO-Wizzard/Views/Root/RootView.swift
- KO-Wizzard/Views/Shared/WorkspaceGradient.swift
- KO-Wizzard/Views/SideBar/SidebarListArea.swift
- KO-Wizzard/Views/SideBar/SidebarRow.swift
- KO-Wizzard/Views/SideBar/SidebarView.swift
- KO-Wizzard/Views/ToolBar/WorkspaceToolbarView.swift
- KO-Wizzard/Views/WorkspaceView.swift

##### Architecture impact (nur wenn relevant)
- UI-Layer nutzt jetzt ein zentrales Theme (AppTheme) als Source of Truth fuer Farben/Typo/Metriken/Effekte.
- RootView resolved Theme per ColorScheme und steuert Chrome-Overlay/Blend zentral.

##### Behavior / UX notes
- Title-Cards starten oben buendig und haben Suchfeld-Hoehe; Tabs wirken einheitlicher.
- Create-Flow: Import-Button bleibt konstant inline bei Assetklasse/Subgroup.
- Darkmode: Orange Chrome, blauer Glow; Sidebar-Selektion uses Search-Background.
- Subtiler Fensterrahmen macht das App-Fenster im Vollbild erkennbar.

##### Known limitations / TODO (max 5)
- Buttons reagieren teils erst nach 2–3 Klicks (noch zu untersuchen).
- Systemmodus benoetigt erneuten visuellen Smoke-Test fuer alle Views.
- LandingView ist optisch separat gehalten (bewusst), nicht komplett tokenisiert.

##### Verification (zwingend)
- `xcodebuild -project KO-Wizzard.xcodeproj -scheme KO-Wizzard -configuration Debug build` (Build succeeded)

#### ✅ Milestone Summary — 2026-01-12 07:58 (Local)
- **Branch:** feature/LandingButtons/CardHeaders
- **Commit:** 4ac0e51
- **Tag (optional):** backup-before-style-merge-20260112-0454
- **Status:** Build green / App runs (not verified) / git status clean

##### Scope (was war das Ziel?)
- Landing-Buttons konsistent zu Toolbar-Styles, Sidebar-Selektion dezenter, Title-Cards zentriert und Debug-Theme-Override standardmaessig deaktiviert, damit System-Appearance wirkt.

##### Changes (was wurde geaendert?)
- Landing-Buttons nutzen Theme-Farben fuer Light/Dark inkl. Glow und erhalten eine schwebende Hover-Anmutung.
- Debug-Theme-Override bleibt erhalten, ist aber standardmaessig deaktiviert; Systemmodus folgt wieder dem OS.
- Sidebar-Selektion leicht in App-Button-Blau abgesetzt (sehr geringe Opacity).
- Title-Cards in allen Tabs zentriert ausgerichtet.

##### Files touched (Whitelist / Ueberblick)
- KO-Wizzard/Views/Landing/LandingView.swift
- KO-Wizzard/KO_WizzardApp.swift
- KO-Wizzard/Style/AppTheme.swift
- KO-Wizzard/Views/Content/ContentRouterView.swift
- KO-Wizzard/Views/Content/InstrumentCreateView.swift
- KO-Wizzard/Views/Content/Tabs/InstrumentCalcView.swift

##### Architecture impact (nur wenn relevant)
- Keine strukturellen Aenderungen; Theme-Override-Logik nur im App-Entry angepasst.

##### Behavior / UX notes
- Landing-Buttons: Light/Dark konsistent zur Toolbar, Hover wirkt schwebender.
- Sidebar-Selektion wirkt dezenter und klarer abgesetzt.
- Title-Cards der Tabs sind jetzt mittig ausgerichtet.
- System-Appearance greift wieder automatisch (Debug-Override standardmaessig aus).

##### Known limitations / TODO (max 5)
- —

##### Verification (zwingend)
- `xcodebuild -project KO-Wizzard.xcodeproj -scheme KO-Wizzard -configuration Debug -destination 'platform=macOS' build` (Build succeeded)
- Sanity-Check: Build gruen; keine App-Run-Pruefung.
