# Relazione II: LAR Splitting 2D

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

In questa sezione si illustreranno passo passo tutti i vari cambiamenti che sono stati fatti per poter ottimizzare, migliorare il codice e la sua velocità computazionale attraverso l'utilzzo della macchina _DGX-1_ del dipartimento di _matematica e fisica Roma Tre_. 
Per quanto riguarda la parte precedente del codice, è presente una descrizione accurata dei vari dati acquisiti attraverso i nostri calcolatori e descritti nella relazione precedente, visitabile all'indirizzo qui di seguito: https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/relazioni/relazione02.md

Abbiamo continuato il nostro studio sulle macro per poter parallelizzare e migliorare la velocità computazionale delle varie funzioni; Nello specifico ci siamo soffermati questa volta sullo studio di due nuove macro: _@async_ e _@views_:

* **@async**: questa macro crea e pianifica le attività per tutto il codice all'inteno della sua attività. E' similare alla macro _@spawn_ con la differenza che runna le task solo a livello locale 
* **@views**: con views si possono creare delle viste degli array che ci permettono di accedere ai valori di quest'ultimo senza effettuare _nessuna copia_

* **@btime**: questa macro svolge lo stesso lavoro di _@benchmark_ ma restituisce un output 
meno complesso e più intuitivo, stampando a schermo le velocità di calcolo delle funzioni

* **@benchmark**: Ci permette di valutare i parametri della funzione in maniera separata; Richiama la funzione più volte per creare un campione dei tempi di esecuzioni restituendo i tempi minimi, massimi e medi.

* **@code_warntype**: ci consente di visualizzare i tipi dedotti dal compilatore, identificando così tutte le instabilità di tipo nel codice preso in esame.

Per quanto riguarda l'ottimizzazione e la parallelizzazione delle funzioni, sono state impiegate le seguenti macro:

* **@threads**: l'utilizzo di questa macro è fondamentale per indicare a _Julia_  la presenza di **loop** che identificano _regioni multi-thread_.

* **@spawn**: identifica uno degli stumenti cardini di _Julia_ per l'assegnazioni dei vari compiti per le task. 

## Studio delle funzioni ottimizzate

Per vedere nel dettaglio i dati ed i benchmark che riporterò qui di seguito, riporto il link diretto: 
    
* https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/tree/main/docs/benchmark 


1) **spaceIndex**: attraverso lo strumento _@code_warntype_, è emersa un'instabilità in alcune variabili e non dell'intero metodo. Nel particolare sono _type unstable_: bboxes, xboxdict, yboxdict, zboxdict, xcovers, ycovers, zcovers ed infine covers.
 Affinando il codice (in altre parole cercando di eliminare i vari if/else che equivalgono ad una cattiva ottimizzazione del codice) e creando un funzione di supporto denominata _removeIntersection_ abbiamo raggiunto i seguenti risultati.
    * Tipo: instabile
    * Velocità di calcolo: 
        * iniziale: 108.350 μs 
        * modificata: 108.182 μs
 
 2) **boundingBox**: sempre attraverso l'utilizzo della funzione denominata _@code_warntype_, è risultata un'instabilità in questo metodo. L'instabilità è dovuta unicamente alla funzione _mapslices_.
 Per ovviare a tale problematica abbiamo richiamato la funzione _hcat_ che concatena due array lungo due dimensioni rendendo boundingbox _type stable_ aumentando notevolmente le prestazioni. (per verificarlo abbiamo richiamato _@benchmark_ e comparato i risultati)
    * Tipo: instabile
    * Velocità di calcolo: 
        * iniziale:   20.202 μs 
        * modificata: 13.282 μs


 3) **boxcovering**: boxcovering è type stable ma la variabile covers è un array di Any. Si procede tipizzando covers e dividendo la funzione in microtask.
    * Tipo: stabile
    * Velocità di calcolo: 
        * iniziale:   8.936 μs 
        * modificata: 4.499 μs

 4) **pointInPolygonClassification**: funzione di notevole importanza nel nostro progetto. In questo caso abbiamo scomposto i vari else/if in tante _mono-task_ per poter alleggerire il codice di quest'ultima.
 Nella figura sottostante vedremo come lavora _pointInPolygon_, denotando tutti quei segmenti che intersecano le facce del poligono preso in esame. Nello specifico nel punto (a) vediamo i singoli segmenti (o linee) che intersecano quest'ultime; Nel punto (b) vengono illustrati tutti quei punti che sono situati esternamente, internamente o sul bordo della faccia del poligono, nel punto (c) vengono cancellati tutti quei segmenti che vanno verso l'esterno della faccia del poligono e per finire vediamo nel punto (d) il risultato finale attraverso il **TGW** in 2D.
    * Tipo: stabile
    * Velocità di calcolo: 
        * iniziale:   123.196 μs
        * modificata: 122.009 μs


![Lavoro di pointInPolygonClassification](https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/docs/plots/images/Schema_pointInPolygon.png?raw=true)

#

 ## Funzioni aggiuntive create
 
 In questa sezione verranno illustrate tutte le funzioni secondarie da noi utilizzate create per migliorare, alleggerire e semplificare gran parte del codice.

 * **addIntersection**(covers::Array{Array{Int64,1},1}, i::Int64, iterator) aggiunge gli elementi di iterator nell'i-esimo array di covers.

 * **createIntervalTree**(boxdict::AbstractDict{Array{Float64,1},Array{Int64,1}}) dato un insieme ordinato, crea un intervalTree; Nel particolare parliamo di una struttura dati che contiene intervalli e che ci consente di cercare e trovare in maniera efficiente tutti gli intervalli che si sovrappongono ad un determinato intervallo o punto.

 * **removeIntersection**(covers::Array{Array{Int64,1},1}):
 siamo riusciti a rendere più stabile il tutto diminuendo in linea generale i tempi di calcolo della funzione stessa.
 Quest'ultima elimina le intersezioni di ogni boundingbox con loro stessi.

## Test delle funzioni principali e aggiuntive

inizialmente si è sono eseguiti i test pre-esistenti per verificare il corretto funzionamento delle funzioni principali anche dopo aver effettuato lo studio di parallelizzazione con le macro dei singoli task. Dopo aver verificato il successo di questi, si è proceduto alla realizzazione di nuovi test:

* **@testset "createIntervalTree test"**: creato un _OrderedDict_ e un _intervaltrees_ vogliamo testare che i dati siano stati disposti nel giusto ordine nella struttura dati. Per farlo estraiamo i singoli valori e li confrontiamo con i valori che ci aspettiamo di trovare nelle singole locazioni.

* **@testset "removeIntersection test"**: avendo isolato il task della funzione spaceindex che rimuove le intersezioni dei singoli boundingbox con se stesso, vogliamo assicurarci che funzioni nel modo corretto. Per farlo creiamo un array covers di test e controlliamo che la funzione modifichi la struttura dati nel modo corretto per ogni valore.

* **@testset "addIntersection! test"**: avendo isolato il task della funzione _boxcovering_ che aggiunge in 'covers' in i-esima posizione tutti i bounding box che intersecano l'i-esimo bounding box, vogliamo assicurarci che funzioni nel modo corretto. Per farlo creiamo un boundingbox di test e un OrderedDict con cui creare un _intervalTree_. A questo punto diamo queste variabili come input alla nostra funzione e confrontiamo il risultato ottenuto con quello atteso.

Per quanto rigurdano i test delle funzioni principali da noi studiate, abbiamo svolto con successo i test sulle funzioni iniziali dando i risultati aspettati.
Solo successivamente (con un po' di difficoltà) abbiamo svolto i test sulle funzioni da noi modificate arrivando alla completa correttezza di quest'ultimi.
nello specifico si possono revisionare i vari test nei vari _notebook02_  aggiornati, seguendo il link qui riportato:
https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/tree/main/notebook

## PARALLELIZZAZIONE

Durante lo studio preliminare ed esecutivo, abbiamo cercato di ottimizzare il nostro codice sia a livello di CPU che GPU.
Considerato questo, abbiamo deciso di concentrarci maggiormente sulla parallelizzazione su CPU.
Per la parallelizzazione su CPU abbiamo utilizzato le macro sopra elencate: _@threads_ e _@spawn_. La prima viene usata su un ciclo for per dividere lo spazio di iterazione su più thread secondo una certa politica di scheduling, mentre la seconda permette di eseguire una funzione su un thread libero nel momento dell'esecuzione. **@threads** viene usata nella funzione removeIntersection(), boxcovering() e infine in addIntersection!(), mentre **@spawn** viene usata principalmente nella funzione spaceindex().
Per eseguire questo tipo di parallelizzazione bisogna tenere conto del numero di core presenti sulla macchina e proprio per questo motivo abbiamo provato a lavorare con la **workstation DGX-1** di _nvidia_  per poter raggiungere prestazioni migliori. Anche con ciò, si è notato che utilizzare un numero di thread maggiore di quelli disponibili non porta ad un aumento delle prestazioni.
Il numero di thread da assegnare ai vari processi processi julia va stabilito prima dell'avvio e può essere controllato e settato tramite la funzione _nthreads()_.

Nel grafico sottostante, abbiamo testato le prestazioni di _spaceindex()_ al variare del numero di thread. Nello specifico quando si hanno a disposizione uno, quattro o otto thread (il massimo ottenibile dalla worksation DGX) e analizzando i tempi, si evince che il numero di thread deve essere scelto in base alla complessità del modello preso in esame. Infatti, utilizzando modelli semplici, un numero elevato di thread porta ad un peggioramento delle prestazioni, mentre all'aumentare della complessità si ha un miglioramento.

## Grafo delle dipendenze aggiornato

In sintesi, questo **grafo** rappresenta il lavoro svolto sino ad ora con tutte le nuove funzioni create, aggiornate ed aggiunte.
I nodi color celeste sono le funzioni di supporto, i nodi colorati di rosso sono le funzioni principali della classe e gli ultimi colorati di blu sono funzioni secondarie equamente importanti alla fine del progetto stesso.
Nello specifico il nodo _Utility_function_PointInPolygon_1-15_  racchiude tutte le 15 funzioni create per il supporto a PointInPolygonclassification.


 ![Grafo delle dipendenze della classe Refactoring (Aggiornato)](https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/docs/plots/images/grafoRefactoring_V2.1.png?raw=true)


