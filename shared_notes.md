# Work Package 0 
* Zugang zu Servern / Rstudio etc
* Aufgaben Lisa:
  * Sentinel-Szenen für Rheinland-Pfalz raussuchen
  	* 1 Szene Ende Juni/Juli
  	* 1 Szene Winter
* Identifikation von Trainingsgebieten:
	* Wald/Nicht-Wald (mit Hansen)
	* Polygone >80% Anteil einer Baumart
		* Eindeutig trennbare Mischpolygone (1 Laubbaumart + 1 immergrüner Nadelbaumart)
* Keine Veränderung laut Hansen (< 5% loss)

# Work Package 1

2020-07-08

## Sentinel Daten:

* 20m Auflösung
* Indices berechnen
* RStoolbox::SpectralInd()


## Lidar Daten:
* CHM mit 20m Auflösung
* Hansen-Daten als Maske
* Vegetation Height < 10m als Maske    
* Indizes berechnen mit Sentinel Grid als Basis

 
## General
* Forstdaten: 2009
* LiDAR: 2009-2016
* Sentinel: 2019



## Potentielle Masterarbeit:

Model training with Metadata    

* Lidar Daten zw. 2009 und 2017
* Datenaufnahme 2009

Was macht die Zeitdifferenz bei der Modellierung aus?
Aufnahmejahr als Prädiktor?
Vergleich mit Aufnahme 
