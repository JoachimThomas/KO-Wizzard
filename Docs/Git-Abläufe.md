1) Status prüfen
   git status

2) Alle Änderungen aufnehmen (stagen)
   git add .

3) Commit erstellen
   git commit -m "Kurzbeschreibung der Änderung"

   Beispiel:
   git commit -m "Fix sidebar collapse and footer styling"

4) Sicherstellen, dass du auf main bist
   git branch --show-current

   Falls nicht:
   git checkout main

5) Falls nötig: anderen Branch mergen
   git merge <branch-name>

6) Änderungen zu GitHub hochladen
   git push

----------------------------------------

Notfall-Kurzform (wenn du sicher auf main bist):

   git add .
   git commit -m "..."
   git push

----------------------------------------

Merksatz:
Arbeitsordner → add → commit → push → GitHub
Chaos → Paket → Version → Sicherung