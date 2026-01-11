# KO-Wizzard – Project Anchor

## Projektstatus (Stand: nach Cleanup, v1.0)

Die App ist funktional vollständig und stabil.

### Kernfunktionen
- Instrumente erfassen, anzeigen, bearbeiten
- Berechnung (Underlying ↔ Zertifikat)
- Sidebar mit:
  - Assetklasse → Subgroup → Richtung (Long/Short)
  - alles collapsable
  - Book-Button: global collapse / expand (WYSIWYG)
  - letzter Eintrag bleibt markiert (lastModified)

### UI & Design
- LandingPage mit 3 großen Glossy-Buttons
- Farbkonzept: Blau / Orange, DarkMode vorbereitet
- Titlebar & Footer mit Glas + Farbverlauf
- Sidebar leicht getönt, Content klar, Menlo als Standardfont
- Nirvana-Fade am unteren Rand der Sidebar

### Architekturregeln
- Keine neuen Views ohne klaren Bedarf
- Keine neuen globalen States ohne Diskussion
- AppStateEngine ist zentrale Logik
- InstrumentCreateFlow + Edit-Flow nutzen dieselben Mechaniken
- Keine Features mehr — ab jetzt nur noch UI/UX & Polishing

### Entwicklungsregeln
- Kleine Schritte
- Jeder Schritt: Commit + Push
- Erst Analyse → dann Umsetzung
- Keine „kreativen Abkürzungen“