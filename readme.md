# WS24/25 Piraten Kapern Programmier-Praktikum


**Piraten Kapern** ist ein kurzweiliges Würfelspiel für 2–4 Spieler. Schlüpfe in die Rolle eines alten Seeräubers und tritt gegen andere holzbeinige Zauselbärte an! Hier ist Spaß garrrrrrrrrrrantiert 😄

## Realisierung



- [Das Windows Programm(EXE)](https://lms.fh-wedel.de/pluginfile.php/59387/mod_book/chapter/646/PiratenKapern.exe)
- [Das Benutzerhandbuch](https://lms.fh-wedel.de/pluginfile.php/59387/mod_book/chapter/646/PiratenKapern.exe)
- [Das Programmierhandbuch](https://lms.fh-wedel.de/pluginfile.php/59387/mod_book/chapter/646/PiratenKapern.exe)
- [Der Source-Code ](https://lms.fh-wedel.de/pluginfile.php/59387/mod_book/chapter/646/PiratenKapern.exe)


![Beispielbild](https://lms.fh-wedel.de/pluginfile.php/59387/mod_book/chapter/646/Beispielbild.jpg)




## Aufgabenstellung

Es soll ein *Piraten Kapern Spiel* als Windows Programm erstellt werden. Dabei ist die Programmiersprache Delphi zu verwenden.  

### Einstellungen

- Vor Spielbeginn: Anzahl der Spieler (2–4) und eindeutige Namen eingeben
- Neues Spiel kann jederzeit gestartet werden

### Regeln

Die [Original-Spielregeln (PDF)](https://lms.fh-wedel.de/pluginfile.php/59387/mod_book/chapter/646/Spielanleitung.pdf) müssen umgesetzt werden. Zusätzlich gelten folgende Abweichungen/Ergänzungen:

- 2–4 Spieler
- Punktestand direkt im Programmfenster
- Spieler 1 beginnt, dann reihum
- Piratenkarten werden automatisch aufgedeckt
- Kein Ablagestapel, Kartenstapel wird recycelt
- Spiel endet sofort, wenn jemand 6000 Punkte erreicht

Folgendes ist im Fenster sichtbar und interaktiv:

- Namen & Punkte aller Spieler, aktueller Spieler hervorgehoben
- Aktuelle Piratenkarte
- Tisch mit aktuellen Würfeln in zufälliger Positionierung
- Totenkopf-Würfel visuell hervorgehoben
- "Geschützter Bereich" mit gesicherten Würfeln (Raster, sortiert)
- Schatzinsel-Bereich bei entsprechender Karte (ähnlich dem geschützten Bereich)
- Würfelbewegung per Linksklick (schützen/entschützen), Rechtsklick (Schatzinsel)
- Totenkopfwürfel können nicht gesichert werden
- Wächterin-Karte: einmaliges Neuwürfeln eines Totenkopfes möglich
- Verlorener Zug / Totenkopfinsel: grafische Hervorhebung (z. B. roter/schwarzer Rahmen)

Buttons:

- Würfeln
- Wurf werten
- Neues Spiel starten
- Spielstand laden/speichern
- Log ein-/ausblenden
- Spiel beenden (mit Rückfrage bei Spielstandsverlust)


### Ereignislog

- Vollständiges Log im Fenster anzeigen
- Muss den Spielverlauf vollständig nachvollziehbar machen
- Log wird beim neuen Spiel gelöscht

## Spielstand

Speichern und Laden von Spielständen ist möglich (Dateiendung `.pk`):

### Format:

1. Zeile: Anzahl der Spieler (2–4)  
2. Zeile: Spieler am Zug (1–n)  
3. Zeile+: `<Name>,<Punktzahl>` pro Spieler  
Danach: Kartenstapel als kommaseparierte Zahlen (Ordinalwerte der Karten):

| Karte           | Wert | Anzahl |
|------------------|------|--------|
| Animals          | 0    | 4x     |
| Diamond          | 1    | 4x     |
| GoldCoin         | 2    | 4x     |
| Guardian         | 3    | 4x     |
| Pirate           | 4    | 4x     |
| PirateShip2      | 5    | 2x     |
| PirateShip3      | 6    | 2x     |
| PirateShip4      | 7    | 2x     |
| Skull1           | 8    | 3x     |
| Skull2           | 9    | 2x     |
| TreasureIsland   | 10   | 4x     |


Fehlerhafte Dateien müssen beim Laden abgefangen werden.

