## :evergreen_tree: :deciduous_tree:	 ForestModellingRLP

Modelling successional stages for forests in Rheinland Pfalz

Epic 1: Publication of Forest modelling paper

* Story 1 Data preparation

    - [ ]

* Story 2 Data modelling

    - [ ]

* Story 3 RLP Prediction and AOA Berechnung

    - [x] aus allen Modellen Lidar Indice raussuchen

    - [x] RLP auf Wald / Nicht-Wald beschneiden

    - [x] Stephan: diese Lidar Indices fuer die Waldflaechen 20 x 20 m ausspucken

    - [X] Prediction für RLP (./scripts/prediction_main.R)
        - Prediction der Hauptbaumarten liegt unter ./predictions inkl. QGIS-Projekt
        Nächste Schritte Lisa:
        - [ ] Prediction für die diversen Baumarten
        - [ ] Bei Kiefer fehlt im Modell die Qualifizierungsphase (gab nur 16 Polygone)


    - [ ] AOA Berechnen (Nico, Marvin)
      - ?wirft AOA Gebiete im Süden mit Mischpixeln raus?

    - [x] Methoden aus Stoffels et al. raussuchen und mit unseren vergleichen
        - Frühling und Sommer kein Winter
        - kein Lidar zum Trainieren nur zum Validieren
        - RapidEye und Spot-4 und 5
        - Clusteranalyse kein RandomForest
        - Modelle wurden Szenenweise gerechnet
        - Drei gleiche Phasen
        - Baumklassen nur die Baumarten die am häufigsten in RP vorkommen

* Story 4 Validierung der Modellergebnisse

        - [ ] Validierung mit "unserem" Testdatensatz
        - [ ] Die Bundeswaldinventurdaten werden für den Einsatz zu Validierung geprüft
        - [ ] Validierung mit Daten von Bundeswaldinventur (Voraussetzung: Bundeswaldinventur Vergleichbarkeit zu unseren Modelldaten)
        - Hauptbaumarten AOA vergleichen mit Diversen Flächen, die nicht in Training eingegangen sind. - passt das überein?
Platzhalter:Gesprächsnotizen
- tradeoff: Mehr Arten, unsichere Vorhersagen vs. weniger Arten vorhersagen, sicherere Vorhersage.

- fallen Testpolygone durch AOA weg, weil wir sie nicht mit drin hatten. 

Validierung: Rausgelassene Gebiete 

    - Datensatz der extrahierten Polygone finden (Marvin) 

Validierung: Vergleich mit Bundeswaldinventur

Vergleich der not-AOA mit Bundeswaldinventur - was können wir nicht vorhersagen??

Vergleich AOA-diverse, AOA-main
main not-AOA -> doch AOA in diverse?
Welche Klasse im non-AOA main ist in diverse?


* Story 5 Manuskript Struktur

    - [ ] Literatur: Stand der Forschung

    - [ ] Aufbau

    - [ ] Abbildungen roh

    - [ ] Fehlermaße aufbereiten
