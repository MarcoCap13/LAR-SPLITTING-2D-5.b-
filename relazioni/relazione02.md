# Relazione LAR Splitting 2D

_Studenti: Caponi Marco, Ceneda Gianluca_

Prime analisi, test e possibili ottimizzazioni sul progetto LAR SPLITTING 2D con l’utilizzo della seguente repository:

* Main repository: https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-

    * https://github.com/cvdlab/LinearAlgebraicRepresentation.jl/blob/master/src/refactoring.jl

    * https://github.com/cvdlab/Lar.jl/blob/master/src/fragface.jl 


## Obiettivi:

* Studio del progetto **LAR SPLITTING 2D** e di tutte le funzioni e strutture dati utilizzate.
* Descrizione di ogni task individuata, tipo e significato di ogni parametro ed eventuale valore di ritorno.
* Suddivisione delle tipologie di funzioni e creazione di grafi delle dipendenze.
* Individuare eventuali problemi riscontrati durante lo studio preliminare del codice.


# RELAZIONE DEL PROGETTO

In questa sezione si illustreranno passo passo tutti i vari cambiamenti che sono stati fatti per poter ottimizzare, migliorare il codice e la sua velocità computazionale.
Nello specifico abbiamo modificato le funzioni principali della classe **Refactoring** e della classe **Fragface**.
Per quanto riguarda la parte precedente del codice, è presente una descrizione accurata nella relazione precedente, visitabile all'indirizzo di seguito: https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/relazioni/relazione01.md

* spaceIndex: attraverso lo strumento **@code_warntype**, è emersa un'instabilità in alcune variabili e non dell'intero metodo. Nel particolare sono _type unstable_: bboxes, xboxdict, yboxdict, zboxdict, xcovers, ycovers, zcovers ed infine covers.
 Affinando il codice (in altre parole cercando di eliminare i vari if/else che equivalgono ad una cattiva ottimizzazione del codice) e creando un funzione di supporto denominata **removeIntersection** siamo riusciti a rendere più stabile il tutto diminuendo in linea generale i tempi di calcolo della funzione stessa.
 
 * boundingBox: sempre attraverso l'utilizzo della funzione denominata **@code_warntype**, è risultata un'instabilità in questo metodo. L'instabilità è dovuta unicamente alla funzione _mapslices_.
 Per ovviare a tale problematica abbiamo richiamato la funzione _hcat_ che concatena due array lungo due dimensioni rendendo boundingbox _type stable_ aumentando notevolmente le prestazioni. (per verificarlo abbiamo richiamato **@benchmark** e comparato i risultati)

 * pointInPolygonClassification: funzione di notevole importanza nel nostro progetto. In questo caso abbiamo scomposto i vari elif in tante _mono-task_ per poter alleggerire il codice di quest'ultima.
 Nella figura sottostante vedremo come lavora pointInPolygon, denotando tutti quei segmenti che intersecano le facce del poligono preso in esame. Nello specifico nel punto (a) vediamo i singoli segmenti (o linee) che intersecano quest'ultime e nel punto (b) vengono illustrati tutti quei punti che sono situati esternamente, internamente o sul bordo della faccia del poligono.


![Lavoro di pointInPolygonClassification](https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/docs/plots/images/Schema_pointInPolygon.png?raw=true)

#### Funzioni secondarie utilizzate dalle funzioni principali: pointInPolygon, spaceindex, boxcovering:

* hcat: concatena due array lungo due dimensioni

* minimum : restituisce il risultato più piccolo della funzione che viene chiamata su ogni elemento dell'array passato come parametro.

* maximum : restituisce il risultato più grande di una funzione che viene chiamata su ogni elemento dell'array passato come parametro.

* min: restituisce il minimo degli argomenti.

* max: restituisce il massimo degli argomenti.

* intersect: restituisce l’intersezione di due insiemi.

* enumerate : un iteratore che produce (i, x) dove i è un contatore a partire da 1, e x è il valore i-esimo della collezione su cui scorre l'iteratore dato.

* haskey : determina se una collezione ha una mappatura per una determinata chiave.

* Mapslices: trasforma le dimensioni date dell'array in input usando una funzione scelta dall’utente. La funzione è chiamata su tutte le dimensioni ( slices ) dell’array.

 ## Funzioni aggiuntive create
 
 In questa sezione verranno illustrate tutte le funzioni secondarie da noi utilizzate create per migliorare, alleggerire e semplificare gran parte del codice.

 * **addIntersection**(covers::Array{Array{Int64,1},1}, i::Int64, iterator) aggiunge gli elementi di iterator nell'i-esimo array di covers.

 * **createIntervalTree**(boxdict::AbstractDict{Array{Float64,1},Array{Int64,1}}) dato un insieme ordinato, crea un intervalTree; Nel particolare parliamo di una struttura dati che contiene intervalli e che ci consente di cercare e trovare in maniera efficiente tutti gli intervalli che si sovrappongono ad un determinato intervallo o punto.

 * **removeIntersection**(covers::Array{Array{Int64,1},1})elimina le intersezioni di ogni boundingbox con loro stessi.

 ![Grafo delle dipendenze della classe Refactoring (Aggiornato)](https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/docs/plots/images/FunctionGraph_V2.png?raw=true)


In sintesi, questo **grafo** rappresenta il lavoro svolto sino ad ora con tutte le nuove funzioni create, aggiornate ed aggiunte.
I nodi color celeste sono le funzioni di supporto, i nodi colorati di rosso sono le funzioni principali della classe e gli ultimi colorati di blu sono funzioni secondarie equamente importanti alla fine del progetto stesso.