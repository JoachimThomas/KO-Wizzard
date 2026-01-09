# Git Cheat Sheet – KO-Wizzard

Diese Liste enthält alle Git-Befehle, die im Alltag für dieses Projekt benötigt werden,
mit kurzer Erklärung, damit jederzeit nachgeschlagen werden kann.

---

## Überblick & Status

### Aktueller Zustand des Repos
git status  
→ Zeigt geänderte Dateien, neue Dateien, aktuellen Branch und ob alles sauber ist.

### Änderungen anzeigen
git diff  
→ Zeigt die konkreten Code-Änderungen seit dem letzten Commit.

---

## Änderungen speichern

### Alle Änderungen vormerken
git add -A  
→ Fügt alle neuen, geänderten und gelöschten Dateien zum Commit hinzu.

### Änderungen speichern
git commit -m "Beschreibung"  
→ Speichert die Änderungen mit Kommentar.

### Änderungen zu GitHub hochladen
git push  
→ Lädt die lokalen Commits ins Remote-Repository.

---

## Arbeiten mit Branches

### Neuer Arbeits-Branch
git switch -c feature/name  
→ Erstellt einen neuen Branch und wechselt hinein.

### Zum Hauptzweig zurück
git switch main  
→ Wechselt zurück zum stabilen Hauptstand.

### Branch löschen (wenn Feature verworfen wird)
git branch -D feature/name  
→ Löscht den Branch vollständig.

---

## Aktualisieren & Synchronisieren

### Aktuellen Stand vom Server holen
git pull  
→ Holt die neuesten Änderungen vom Remote-Repository.

---

## Rückgängig machen

### Alle lokalen Änderungen verwerfen
git restore .  
→ Setzt alle noch nicht gespeicherten Änderungen zurück.

### Eine einzelne Datei zurücksetzen
git restore Pfad/zur/Datei.swift  
→ Setzt nur diese Datei zurück.

### Letzten Commit rückgängig machen (sicher)
git revert HEAD  
→ Erstellt einen neuen Commit, der den letzten Commit aufhebt.

---

## Notfall-Werkzeuge

### Komplett auf letzten Commit zurücksetzen (Vorsicht)
git reset --hard HEAD  
→ Verwirft alle lokalen Änderungen.

### Ungetrackte Dateien löschen
git clean -fd  
→ Löscht Dateien, die nicht unter Versionskontrolle stehen.

---

## Empfohlener Standard-Workflow

1) Neuer Branch:
git switch -c feature/neues-feature

2) Arbeiten im Code …

3) Änderungen prüfen:
git status  
git diff

4) Speichern:
git add -A  
git commit -m "Neues Feature"

5) Hochladen:
git push -u origin feature/neues-feature

Wenn das Feature verworfen wird:
git switch main  
git branch -D feature/neues-feature
