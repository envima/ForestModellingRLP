# Gesprächsnotizen mit Hanna
* keine >300 folds sondern 10x folds (mit Leaf-Polygon-Out)
* CAST-Version 0.4.2 mit "class" Parameter in CreateSpaceTimeFold für e.g. Baumarten 
* kein Tuning bei RandomForest
* 51 Bäume statt 500 
* AOA aus CAST verwenden um zu schauen für welchen Teil der Karte wir außerhalb des Prädiktorraums sein könnten
 
 
# Neue Erkenntnisse

2020-07-23 - 17:15

* keine 333-fache leave location out cv! Dauert ewig. 10-fach reicht
* ranger rechnet default auf allen Kernen die er findet -> wir nehmen doch randomForest
* ein ffs-durchlauft dauert ca. 15 s, macht 3,5 Tage fuer die Hauptbaumarten



 
 
