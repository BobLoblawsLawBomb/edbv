edbv
====

Programmablaufüberlegungen
--------------------------
* Import Video
* Einzelne Frames durchgehen
* Tisch ausschneiden (maske erstellen)
* Bälle segmentieren, also als resultat soll eine Liste an Masken entstehen die position und form der einzelnen Bälle widerspiegeln. (Connected Component Labeling, Cluster, Glanzlichter, usw.)
* Auf basis jeweils zweier Frames mit Optical Flow die Geschwindigkeitvektoren ermitteln.
* Für jede Komponente eine mittlere Geschwindigkeit errechnen und mit hilfe dieser den selbe Komponente im nächsten Frame wiedererkennen.
* Das Resultat ist für jeden Frame eine Liste mit Komponent-Positionen/Masken
* Auf basis dieser Informationen können Outputs generiert werden (Bild mit linien, geschwindigkeiten, usw.)

Funktionen und Schnittstellen, Ablauf
-------------------------------------
Vorbearbeitung: 
* Video Einlesen
* Maske für Tisch <- Funktion zum Ausschneiden. Input: 1. Frame des Videos
**(Max)**

* VektorMatrix anlegen die für jeden Frame für jeden Ball einen Positionsvektor speichert
* VektorMatrix anlegen die für jeden Frame für jeden Ball einen Richtungsvektor speichert

Schleife läuft über jeden Frame im Video:
* Component Labeling auf Frame anwenden Input: Video-Frame Output: Maske in der alle Bälle eindeutig via farben gekennzeichnet sind.
 => Genauer Durchlauf mittels Glanzlichtern: Eingabe: Jede Component als Bild (volle Größe), Originalbild; Ausgabe: Die einzelnen Kugeln als Bild
**(Theresa)**

* Beim ersten durchlauf werden lediglich die Components erkannt
**(Florian, Theresa)**

* Optimieren der Erkennung der Grünen Kugel
**(Max)**

* Erstellen der Positions- und Richtungsvektorliste, Farbe der Components mitteln und in Lookup-Tabelle schreiben 
**(Florian, Gerald)**

* Bei allen weiteren durchläufen wird die letzte Positions- und Richtungs-vektor-liste verwendet um möglichst die neu erkannten Components wieder den gleichen Components vom letzten Frame exakt zuordnen zu können.

* OpticalFlow anwenden Input: Video-Frame Output: Matrix in der für einen Raster über dem Bild jeweils Richtungsvektoren gespeichert sind.
**(Andreas, Gerald)**

* Component-Flow-Matching funktion anwenden Input: Component-Maske, OpticalFlow-Matrix, Output: Array mit Richtungsvektoren der einzelnen Components
**(Andreas, Gerald)**

* Funktion anwenden die Position der Components bestimmt: Input Component-Maske Output: Array mit Positionsvektoren der einzelnen Components
**(Gerald)**

* Positionsvektoren und Richtungsvektoren zu den Frame-Übergreifenden Matrizen hinzufügen.
**(Gerald)**

Nachbearbeitung: 
* Funktion die basierend auf den Component Positionen und Richtungen der einzelnen Frames Linien in den korrekten Farben über den letzten Frame des Videos zeichnet. Input: VektorMatrix der Component Positionen, VektorMatrix der Component Richtungen, Letzter Video-Frame. Output: Bild mit darübergelegten Linien.
**(im Prinzip fertig; Gerald, Andreas)**

--------------------------------------
| Update: 11.11.2013 - Offene Punkte |
--------------------------------------

Main:
- VektorMatrix anlegen die für jeden Frame für jeden Ball einen Positionsvektor speichert
- VektorMatrix anlegen die für jeden Frame für jeden Ball einen Richtungsvektor speichert
- Ersten ComponentLabeling-Aufruf starten
- Neue Positionen in die Matrix schreiben (Funktion verwenden)
- Weitere Durchläufe mittels “vermutlicher” Position (anhand der alten Positionen und OpticalFlow)
- Positions- und Richtungsvektoren schreiben (=> wenn eine Kugel in einem Loch verschwindet, müssen trotzdem Werte in die Matrix geschrieben werden: letzter Wert (bei Positionsvektoren) bzw. 0 (bei Richtungsvektoren)

Funktion zum Ermitteln der neuen (zu erwartenden) Position einer Komponente.
Eingabe: Maske der Componente, Richtungsvektor, Unsicherheitsfaktor, Originalbild
Ausgabe: Neue Maske

Zuverlässigkeit der Kugelerkennung (Grün)

Farben für die Einträge der Matrix hinterlegen (zum Nachzeichnen der Vektoren)
=> Funktionen zum Zeichnen der Linien soll die Farben berücksichtigen

Funktion, die die Vektormatrix der Positionsvektoren definiert (mit Anzahl der Kugeln)
Funktion, die der Vektormatrix der Positionsvektoren einen Eintrag (pro Frame) für eine Kugel hinzufügt

Funktion, die die Vektormatrix der Richtungsvektoren definiert (mit Anzahl der Kugeln)
Funktion, die der Vektormatrix der Richtungsvektoren einen Eintrag (pro Frame) für eine Kugel hinzufügt

Funktion zum Anlegen der Matrix für die  Farben (die Reihenfolge muss der Reihenfolge der Kugeln)

⇒ evtl. die beiden Funktionen zusammenlegen (1 Vektor mit 4 Einträgen => Die beiden ersten Einträge entsprechen der Position und die nachfolgenden dem Richtungsvektor)

Funktion zum Anwenden von OpticalFlow
Eingabe: Video-Frame
Ausgabe: Matrix mit Richtungsvektoren für einen Raster über dem Bild

Funktion zum Matchen von Component-Flow
Eingabe: Component-Maske, OpticalFlow-Matrix 
Ausgabe: Array mit Richtungsvektoren der einzelnen Components
