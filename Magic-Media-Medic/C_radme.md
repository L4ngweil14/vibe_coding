nach c

Schritt 1: Die "PRÜFEN"-Analyse
Führe diesen Befehl aus, um zu sehen, welche behaupteten Endungen die meisten Probleme machen:

Bash

grep "PRÜFEN" todo_v4_diagnose.csv | cut -d';' -f2 | sort | uniq -c | sort -nr | head -n 15
Schritt 2: Deep-Check der Mime-Types
Und direkt danach schauen wir, was der Computer glaubt, was drin steckt (Mime-Type):

Bash

grep "PRÜFEN" todo_v4_diagnose.csv | cut -d';' -f3 | sort | uniq -c | sort -nr | head -n 15
