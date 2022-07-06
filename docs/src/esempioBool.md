## Esempio `splitting`
```julia
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL = ViewerGL


function randlines(n=300, t=0.4)
	#n = 100 #1000 #1000 #20000
	#t = 0.4 #0.15 #0.4 #0.15
	V = zeros(Float64,2,2*n)
	EV = [zeros(Int64,2) for k=1:n]
	for k=1:n
		v1 = rand(Float64,2)
		v2 = rand(Float64,2)
		vm = (v1+v2)/2
		transl = rand(Float64,2)
		V[:,k] = (v1-vm)*t + transl
		V[:,n+k] = (v2-vm)*t + transl
		EV[k] = [k,n+k]
	end

	V = GL.normalize2(V)
	model = (V,EV)
	Sigma = Lar.spaceindex(model)

	model = V,EV;
	W,EW = Lar.fragmentlines(model);
	U,EVs = Lar.biconnectedComponent((W,EW::Lar.Cells));
	EV = convert(Lar.Cells, union(EVs...))
	V,FVs,EVs = Lar.arrange2D(U,EV)
end

V,FVs,EVs = randlines()

GL.VIEW(GL.GLExplode(V,FVs,1.2,1.2,1.2,1));
GL.VIEW(GL.GLExplode(V,FVs,1.2,1.2,1.2,3,1));
GL.VIEW(GL.GLExplode(V,FVs,1.2,1.2,1.2,99,1));
GL.VIEW(GL.GLExplode(V,FVs,1.,1.,1.,99,1));
GL.VIEW(GL.GLExplode(V,EVs,1.2,1.2,1.2,1,1));
```
Riportiamo un esempio di _splitting_ effettuato durante lo studio definitivo del progetto attraverso due screenshot fondamentali:

![Lavoro di splitting (1)](https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/examples/2d/image/splitting_figura1.png?raw=true=150x) ![Lavoro di splitting (2)](https://github.com/MarcoCap13/LAR-SPLITTING-2D-5.b-/blob/main/examples/2d/image/splitting_figura2.png?raw=true=150x)

Nella **prima figura** (di sinistra) vediamo le intersezioni del bounding-box i-esimo con i restanti boundingbox e nella **seconda figura** vediamo la generazione dei punti dell'intersezioni tra le varie parti.
