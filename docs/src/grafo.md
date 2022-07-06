## Grafo delle dipendenze originale

In questa parte, ci soffermiamo sulla creazione del primo grafo delle dipenzenze sulla base del codice originale oggetto di studio nella prima parte del corso.
Ogni arco orientato rappresenta una _chiamata di funzione_, ogni nodo ha un'etichtta che rappresenta il nome della funzione stessa.
Per quanto riguardano gli archi, ognuno di essi, presenta un numero progressivo che corrisponde all'ordine delle chiamate dal nodo origine.


![Grafo delle dipendenze Originale](https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/docs/plots/images/grafoRefactoring.png?raw=true)

## Grafo delle dipendenze definitivo


In sintesi, questo **grafo** rappresenta il lavoro finale svolto con tutte le nuove funzioni create, aggiornate ed aggiunte.
I nodi color celeste sono le funzioni di supporto, i nodi colorati di rosso sono le funzioni principali della classe e gli ultimi colorati di blu sono funzioni secondarie equamente importanti alla fine del progetto stesso.
Nello specifico il nodo _Utility_function_PointInPolygon_1-15_  racchiude tutte le 15 funzioni create per il supporto a PointInPolygonclassification.


 ![Grafo delle dipendenze della classe Refactoring (Aggiornato)](https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/docs/plots/images/grafoRefactoring_V2.png?raw=true)

