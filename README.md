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
* VektorMatrix anlegen die für jeden Frame für jeden Ball einen Positionsvektor speichert
* VektorMatrix anlegen die für jeden Frame für jeden Ball einen Richtungsvektor speichert

Schleife läuft über jeden Frame im Video:
* Component Labeling auf Frame anwenden Input: Video-Frame Output: Maske in der alle Bälle eindeutig via farben gekennzeichnet sind.
* Beim ersten durchlauf werden lediglich die Components erkannt
* Bei allen weiteren durchläufen wird die letzte Positions- und Richtungs-vektor-liste verwendet um möglichst die neu erkannten Components wieder den gleichen Components vom letzten Frame exakt zuordnen zu können.
* OpticalFlow anwenden Input: Video-Frame Output: Matrix in der für einen Raster über dem Bild jeweils Richtungsvektoren gespeichert sind.
* Component-Flow-Matching funktion anwenden Input: Component-Maske, OpticalFlow-Matrix, Output: Array mit Richtungsvektoren der einzelnen Components
* Funktion anwenden die Position der Components bestimmt: Input Component-Maske Output: Array mit Positionsvektoren der einzelnen Components
* Positionsvektoren und Richtungsvektoren zu den Frame-Übergreifenden Matrizen hinzufügen.

Nachbearbeitung:
* Funktion die basierend auf den Component Positionen und Richtungen der einzelnen Frames Linien in den korrekten Farben über den letzten Frame des Videos zeichnet. Input: VektorMatrix der Component Positionen, VektorMatrix der Component Richtungen, Letzter Video-Frame. Output: Bild mit darübergelegten Linien.
