# Git Cheat Sheet – KO-Wizzard

Diese Liste enthält alle Git-Befehle, die im Alltag für dieses Projekt benötigt werden.

---

## Überblick & Status

git status  
→ Aktueller Zustand des Repos

git diff  
→ Zeigt Code-Änderungen seit letztem Commit

---

## Änderungen speichern

git add -A  
→ Alle Änderungen vormerken

git commit -m "Beschreibung"  
→ Änderungen speichern

git push  
→ Commits zum Remote-Repo senden

---

## Branches

git switch -c feature/name  
→ Neuer Arbeitsbranch

git switch main  
→ Zurück zu main

git branch -d feature/name  
→ Branch löschen (nach Merge)

git branch -D feature/name  
→ Branch löschen (erzwingen, ohne Merge)

---

## Synchronisieren

git pull  
→ Neueste Änderungen vom Remote holen

---

## Rückgängig machen

git restore .  
→ Alle lokalen Änderungen verwerfen

git restore Pfad/zur/Datei.swift  
→ Einzelne Datei zurücksetzen

git revert HEAD  
→ Letzten Commit sicher rückgängig machen

---

## Notfall

git reset --hard HEAD  
→ Alles auf letzten Commit zurücksetzen

git clean -fd  
→ Ungetrackte Dateien löschen

---

## 🧭 Empfohlener Standard-Workflow

1) Neuer Branch  
git switch -c feature/neues-feature

2) Arbeiten im Code …

3) Änderungen prüfen  
git status  
git diff

4) Speichern  
git add -A  
git commit -m "Neues Feature"

5) Feature hochladen  
git push -u origin feature/neues-feature

6) Feature in main übernehmen  
git switch main  
git pull  
git merge feature/neues-feature

7) Merge sichern  
git status  
git push

8) Branch aufräumen  
git branch -d feature/neues-feature

Wenn Feature verworfen wird:  
git switch main  
git branch -D feature/neues-feature


Git Cheat Sheet – KO-Wizzard
Solo-Workflow | sicher | nachvollziehbar | stressfrei

Ziel:
Nie wieder hinterher merken, was man vorher hätte wissen sollen.
Fokus: kleine Schritte, saubere Zustände, sichere Rückwege.

Goldene Regeln:
Nie auf main basteln.
Vor jedem neuen Schritt: git status → muss sauber sein.
Nach jeder sinnvollen Etappe: Commit.
Push = Backup (optional, aber sinnvoll).
Keine Panik-Kommandos.

Die 6 wichtigsten Befehle:
git status
git diff
git add -A
git commit -m "Kurz & konkret: was/warum"
git switch <branch>
git switch -c feature/<name>

Standard-Workflow:

Start eines Features:
git switch main
git pull --ff-only
git switch -c feature/<thema>

Arbeiten & Checkpoints:
git status
git diff
git add -A
git commit -m "Sinnvoller Zwischenstand (Build grün)"

Optionales Backup:
git push -u origin feature/<thema>

Feature fertig → Merge nach main:
git switch main
git pull --ff-only
git merge --no-ff feature/<thema> -m "Merge feature/<thema>"
Build prüfen → danach (manuell):
git push
Branch aufräumen:
git branch -d feature/<thema>
git push origin --delete feature/<thema>

Lokale Änderungen verwalten:

Neue / gelöschte Dateien sichern:
git add -A
git commit -m "Add/Remove: Beschreibung"

Alles auf letzten Commit zurücksetzen:
git restore .

Eine einzelne Datei zurücksetzen:
git restore Pfad/zur/Datei

Kurz parken (Stash):
git stash push -m "WIP"
git stash pop

Notfall:
git reset --soft HEAD~1
git reset --hard HEAD~1
git clean -fd

Überblick:
git branch --show-current
git log --oneline --decorate --graph --max-count=20

Abendroutine – Lebensversicherung:
Vor dem Schlafen immer:
git status
git add -A
git commit -m "Checkpoint: Feierabend"
Optionales Backup:
git push
Wenn diese drei Befehle gelaufen sind, kannst du ruhig schlafen.
