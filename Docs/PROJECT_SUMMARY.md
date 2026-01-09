Ziel
----
KO-Wizzard ist eine SwiftUI-App zur Erfassung, Verwaltung und Berechnung von
KO-Zertifikaten. Kernziel ist die Ableitung von realistischen Entry-, TP- und
SL-Marken sowie deren Visualisierung im Chart.

Architektur
------------
- Zentrale AppStateEngine (ObservableObject) als Single Source of Truth
- RootView entscheidet zwischen Landing und Workspace
- Workspace als feste Shell:
  - Toolbar (Tabs / Aktionen)
  - Sidebar (Instrument-Liste, Filter, Suche)
  - Content-Router (umschalten per workspaceMode, kein NavigationStack)
- Strikte Trennung:
  - Views = Darstellung
  - State / Logik = AppStateEngine + Services

Datenmodell
-----------
- Instrument.swift:
  - Stammdaten des KO-Zertifikats
  - Parsing, Formatting, abgeleitete Werte
- ENUM_Constants.swift:
  - Domänen-Enums (AssetClass, Direction, Emittent, Ratio, …)
- InstrumentStore.swift:
  - In-Memory Store + JSON-Persistenz
  - Autosave via Combine

Workflows
---------
1) Create-Flow:
   - Geführter Wizard oder Import via Freitext-Parser
   - Draft-Instrument + Schrittsteuerung im AppState
2) Auswahl:
   - Sidebar setzt selectedInstrumentID
   - Detail-, Trade- und Report-Views reagieren darauf
3) Navigation:
   - Umschaltung ausschließlich über workspaceMode

Aktueller Stand
---------------
- App kompiliert und läuft stabil
- Create-Flow vollständig
- Detail-View vorhanden
- Trade-Tab Platzhalter
- Reports-Tab Hülle vorhanden
- Berechnungen-Tab aktuell auf Detail-View verlinkt (noch leer)

Nächster logischer Entwicklungsschritt
--------------------------------------
- Einführung eines echten Berechnungs-Tabs:
  - Vorwärtsrechner (Basispreis → Zertifikatpreis)
  - Rückwärtsrechner (Zertifikatpreis → Basispreis)
- Reine Berechnungs-Engine (UI-frei, testbar)
- Calc-View instrument-zentriert (selectedInstrument)
