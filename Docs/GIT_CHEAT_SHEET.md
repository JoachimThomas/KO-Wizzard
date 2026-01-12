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
