## :evergreen_tree: :deciduous_tree:	 ForestModellingRLP

Modelling successional stages for forests in Rheinland Pfalz

Projectmanagement:
* [Epics](https://github.com/envima/ForestModellingRLP/blob/master/projmngmt/Epics.md)

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
        - [ ] Die Bundeswaldinventurdaten werden für den Einsatz zu Validierung geprüft

    - [ ] AOA Berechnen

    - [x] Methoden aus Stoffels et al. raussuchen und mit unseren vergleichen
        - Frühling und Sommer kein Winter
        - kein Lidar zum Trainieren nur zum Validieren
        - RapidEye und Spot-4 und 5
        - Clusteranalyse kein RandomForest
        - Modelle wurden Szenenweise gerechnet
        - Drei gleiche Phasen
        - Baumklassen nur die Baumarten die am häufigsten in RP vorkommen

* Story 4 Manuskript Struktur

    - [ ] Literatur: Stand der Forschung

    - [ ] Aufbau

    - [ ] Abbildungen roh 

    - [ ] Fehlermaße aufbereiten


