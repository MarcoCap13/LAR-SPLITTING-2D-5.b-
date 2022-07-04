using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using IntervalTrees
using SparseArrays
using NearestNeighbors
using BenchmarkTools
using OrderedCollections
using Base.Threads

#---------------------------------------------------------------------
#	2D containment test
#---------------------------------------------------------------------

"""
    crossingTest(new::Int, old::Int, count::T, status::Int)

# Explanation

Half-line crossing test. Utility function for `pointInPolygonClassification` function.
Update the `count` depending of the actual crossing of the tile half-line.

# Arguments

- `new::Int`
- `old::Int`
- `count::T`
- `status::Int`
"""
function crossingTest(new::Int, old::Int, count::T, status::Int)::Number where T <: Real
    if status == 0
        status = new
        count += 0.5
    else
        if status == old
        	count += 0.5
        else
        	count -= 0.5
        end
        status = 0
    end
end



"""
	setTile(box)(point)

# Explanation

Set the `tileCode` of the 2D bbox `[b1,b2,b3,b4]:=[ymax,ymin,xmax,xmin]:= x,x,y,y`
including the 2D `point` of `x,y` coordinates.
Depending on `point` position, `tileCode` ranges in `0:15`, and uses bit operators.
Used to set the plane tiling depending on position of the query point,
in order to subsequently test the tile codes of edges of a 2D polygon, and determine
if the query point is either internal, external, or on the boundary of the polygon.
Function to be parallelized ...

```julia
c1,c2 = tilecode(p1),tilecode(p2)
c_edge, c_un, c_int = c1 ⊻ c2, c1 | c2, c1 & c2
```

"""
function setTile(box)
	tiles = [[9,1,5],[8,0,4],[10,2,6]]
	b1,b2,b3,b4 = box
	function tileCode(point)
		x,y = point
		code = 0
		if y>b1 code=code|1 end
		if y<b2 code=code|2 end
		if x>b3 code=code|4 end
		if x<b4 code=code|8 end
		return code
	end
	return tileCode
end


function edgecode1(c_int) #c_edge == 1
    if c_int == 0 return "p_on"
    elseif c_int == 4 crossingTest(1,2,status, counter) end 
end

function edgecode2(c_int) #c_edge == 2
    if c_int == 0 return "p_on"
    elseif c_int == 4 crossingTest(2,1,status, counter) end 
end

function edgecode3(c_int) #c_edge == 3
    if c_int == 0 return "p_on"
    elseif c_int == 4 counter += 1 end 
end

function edgecode4(c_un) #c_edge == 4
    if c_un == 3 return "p_on" end 
end

function edgecode5(c1,c2) #c_edge == 5
    if (c1==0) | (c2==0) return "p_on"
    else crossingTest(1,2,status, counter) end 
end

function edgecode6(c1,c2) #c_edge == 6
    if ((c1==0) | (c2==0)) return "p_on"
    else crossingTest(2,1,status, counter) end 
end

function edgecode7(counter) #c_edge == 7
    counter += 1
end

function edgecode8(c_un) #c_edge == 8 (c_un == 6 su slide)
    if (c_un == 8) return "p_on" end   
end

function edgecode9_10(c1,c2) #c_edge == 9/10
    if ((c1 ==0) | (c2==0)) return "p_on" end
end

function edgecode11() #c_edge == 11
end

function edgecode12(c_un) #c_edge = 12
    if (c_un == 12 ) return "p_on" end    
end

function edgecode13(c1,c2) #c_edge = 13
    if (( c1 ==4) | (c2 == 4))
        crossingTest(1,2,status, counter) end
end

function edgecode14(c1,c2) #c_edge = 14
    if (( c1 ==4) | (c2 == 4))
        crossingTest(2,1,status, counter) end
end

function edgecode15(x1,x2,y1,y2,x,y)
    x_int = ((y-y2)*(x1-x2)/(y1-y2))+x2
    if x_int > x counter+=1
    elseif (x_int == x) return "p_on" end
end

"""
	pointInPolygonClassification(V,EV)(pnt)

# Explanation

Point in polygon classification.

# Example

```julia
result = []
classify = pointInPolygonClassification(V,EV)
```
"""
function pointInPolygonClassification(V,EV) 
    function pointInPolygonClassification0(pnt)
        x,y = pnt
        xmin,xmax,ymin,ymax = x,x,y,y
        tilecode = setTile([ymax,ymin,xmax,xmin])
        count,status = 0,0

        for (k,edge) in enumerate(EV)
            p1,p2 = V[:,edge[1]],V[:,edge[2]]
            (x1,y1),(x2,y2) = p1,p2
            c1,c2 = tilecode(p1),tilecode(p2)
            c_edge, c_un, c_int = c1⊻c2, c1|c2, c1&c2

            if (c_edge == 0) & (c_un == 0) return "p_on"
            elseif (c_edge == 12) & (c_un == c_edge) return "p_on"
            elseif c_edge == 3
                edgecode3(c_int)
            elseif c_edge == 15
               edgecode15(x1,x2,y1,y2,x,y)
            elseif (c_edge == 13) & ((c1==4) | (c2==4))
                    crossingTest(1,2,status,count)
            elseif (c_edge == 14) & ((c1==4) | (c2==4))
                    crossingTest(2,1,status,count)
            elseif c_edge == 7 edgecode7(counter)
            elseif c_edge == 11 count = count
            elseif c_edge == 1
               edgecode1(c_int)
            elseif c_edge == 2
                edgecode2(c_int)
            elseif (c_edge == 4) & (c_un == c_edge) return "p_on"
            elseif (c_edge == 8) & (c_un == c_edge) return "p_on"
            elseif c_edge == 5
                edgecode5(c1,c2)
            elseif c_edge == 6
                edgecode6(c1,c2)
            elseif (c_edge == 9) & ((c1==0) | (c2==0)) return "p_on"
            elseif (c_edge == 10) & ((c1==0) | (c2==0)) return "p_on"
            end
        end
        if (round(count)%2)==1
        	return "p_in"
        else
        	return "p_out"
        end
    end
    return pointInPolygonClassification0
end


#---------------------------------------------------------------------
#	Refactoring pipeline
#---------------------------------------------------------------------

"""
	input_collection(data::Array)::Tuple

*Facet selection*. Construction of a ``(d-1)``-dimensional collection from a ``(d-1)``-
or ``d``-dimensional one. ``0-chain`` of `LAR` type are used as *input*.

*Output* is ``admissible input`` for algorithms of the *2D/3D arrangement* pipeline.

# Example 2D

An assembly of geometric objects is generated, and their assembly, including rotated
and translated chains, is built producing a collection of input LAR models.

```julia
V,(_,EV,FV) = Lar.cuboidGrid([4,4],true);
W,(_,EW,FW) = Lar.cuboidGrid([3,5],true);
mycircle(r,n) = Lar.circle(r)(n)

data2d1 = (V,EV)
data2d2 = Lar.Struct([ Lar.t(2,2), Lar.r(pi/3), Lar.t(-1.5,-2.5), (W,EW) ])
data2d3 = Lar.Struct([ Lar.t(2,2), mycircle(2.5,16) ])
data2d4 = Lar.Struct([ Lar.t(3.5,3.5), mycircle(.25,16) ])
data2d5 = Lar.Struct([ Lar.t(5,3.5), mycircle(.5,16) ])
data2d6 = Lar.Struct([ Lar.t(5,3.5), mycircle(.25,16) ])

model2d = input_collection( [ data2d1, data2d2, data2d3, data2d4, data2d5, data2d6 ] )
V,EV = model2d
VV = [[k] for k in 1:size(V,2)];
using Plasm
Plasm.view( Plasm.numbering(.5)((V,[VV,EV])) )
```
Note that `V,EV` is not a cellular complex, since 1-cells intersect out of 0-cells.

# Example 3D

```julia
V,FV = Lar.sphere(2)([3,4])
EV = Lar.simplexFacets(FV)
mysphere = V,FV,EV

data3d1 = mysphere
data3d2 = Lar.Struct([ Lar.t(0,1,0), mysphere ])
data3d3 = Lar.Struct([ Lar.t(0,0.5,0), Lar.s(0.4,0.4,0.4), mysphere ])
data3d4 = Lar.Struct([ Lar.t(4,0,0), Lar.s(0.8,0.8,0.8), mysphere ])
data3d5 = Lar.Struct([ Lar.t(4,0,0), Lar.s(0.4,0.4,0.4), mysphere ])

model3d = input_collection([ data3d1, data3d2, data3d3, data3d4, data3d5 ])
V,FV,EV = model3d
VV = [[k] for k in 1:size(V,2)];
using Plasm
Plasm.view( Plasm.numbering(1)((V,[VV, EV])) )
```

Note that `V,FV,EV` is not a cellular complex, since 1-cells and
2-cells intersect out of 0-cells.

"""
function input_collection(data::Array)::Lar.LAR
	assembly = Lar.Struct(data)
	return Lar.struct2lar(assembly)
end

#function boundingbox(vertices::Lar.Points)
#   minimum = mapslices(x->min(x...), vertices, dims=2)
#   maximum = mapslices(x->max(x...), vertices, dims=2)
#   return minimum, maximum
#end
"""
    boundingbox(vertices::Lar.Points)

# Explanation

The boundingbox function is used to create the bounding box of a cell,
that is, the smallest measurement box (area, volume, hypervolume) within which all the points are contained.
"""
function boundingbox(vertices::Lar.Points)
    firstDim = vertices[1,:]
    secondDim = vertices[2,:]
     if (size(vertices,1)==3)
        thirdDim = vertices[3,:]
         minimum = Threads.@spawn hcat([min(firstDim...), min(secondDim...), min(thirdDim...)])
         maximum = Threads.@spawn hcat([max(firstDim...), max(secondDim...), max(thirdDim...)])
    else
         minimum = Threads.@spawn hcat([min(firstDim...), min(secondDim...)])
         maximum = Threads.@spawn hcat([max(firstDim...), max(secondDim...)])
    end
    return fetch(minimum),fetch(maximum)
 end

"""
    coordintervals(coord,bboxes)

# Explanation

coordintervals creates an ordered dictionary where the key is the range on a coordinate, and has as its associated value
the index of the corresponding interval in the boundig box
"""
function coordintervals(coord,bboxes)
	boxdict = OrderedDict{Array{Float64,1},Array{Int64,1}}()
	for (h,box) in enumerate(bboxes)
		key = box[coord,:]
		if haskey(boxdict,key) == false
			boxdict[key] = [h]
		else
			push!(boxdict[key], h)
		end
	end
	return boxdict
end

"""
    boxcovering(bboxes, index, tree)

# Explanation

boxcovering calculates which bounding boxes intersect each other.

# Returns

- `covers`
"""
function boxcovering(bboxes, index, tree)
    covers = [[zero(eltype(Int64))] for k=1:length(bboxes)]		#zero(eltype(Int64)) serve per rendere covers type stable
    @threads for (i,boundingbox) in collect(enumerate(bboxes))
        extent = bboxes[i][index,:]
        iterator = IntervalTrees.intersect(tree, tuple(extent...))
        addIntersection(covers, i, iterator)
    end
    return covers
end


"""
	spaceindex(model::Lar.LAR)::Array{Array{Int,1},1}

# Explanation

Generation of *space indexes* for all ``(d-1)``-dim cell members of `model`.

*Spatial index* made by ``d`` *interval-trees* on
bounding boxes of ``sigma in S_{d−1}``. Spatial queries solved by
intersection of ``d`` queries on IntervalTrees generated by
bounding-boxes of geometric objects (LAR cells).

The return value is an array of arrays of `int`s, indexing cells whose
containment boxes are intersecting the containment box of the first cell.
According to Hoffmann, Hopcroft, and Karasick (1989) the worst-case complexity of
Boolean ops on such complexes equates the total sum of such numbers.

# Examples 2D

```
julia> V = hcat([[0.,0],[1,0],[1,1],[0,1],[2,1]]...);

julia> EV = [[1,2],[2,3],[3,4],[4,1],[1,5]];

julia> Sigma = Lar.spaceindex((V,EV))
5-element Array{Array{Int64,1},1}:
 [4, 5, 2]
 [1, 3, 5]
 [4, 5, 2]
 [1, 3, 5]
 [4, 1, 3, 2]
```

From `model2d` value, available in `?input_collection` docstring:

```julia
julia> Sigma =  spaceindex(model2d);
```

# Example 3D

```julia
model = model3d
Sigma =  spaceindex(model3d);
Sigma
```
"""
function spaceindex(model::Lar.LAR)::Array{Array{Int,1},1}
    V,CV = model[1:2]
    dim = size(V,1)
    
    cellpoints = [ V[:,CV[k]]::Lar.Points for k=1:length(CV) ]		    #calcola le celle
    bboxes = [hcat(boundingbox(cell)...) for cell in cellpoints]    #calcola i boundingbox delle celle
    
    xboxdict = coordintervals(1,bboxes)
    yboxdict = coordintervals(2,bboxes)

    # xs,ys sono di tipo IntervalTree
    xs = createIntervalTree(xboxdict)
    ys = createIntervalTree(yboxdict)
    
    xcovers = boxcovering(bboxes, 1, xs)                        #lista delle intersezioni dei bb sulla coordinata x
    ycovers = boxcovering(bboxes, 2, ys)                        #lista delle intersezioni dei bb sulla coordinata x
    covers = [intersect(pair...) for pair in zip(xcovers,ycovers)]      #lista delle intersezioni dei bb su entrambe le coordinate

    if dim == 3
        zboxdict = coordintervals(3,bboxes)
        zs = createIntervalTree(zboxdict)
        zcovers = boxcovering(bboxes, 3, zs)
        covers = [intersect(pair...) for pair in zip(zcovers,covers)]
    end
    
    for k=1:length(covers)
		covers[k] = setdiff(covers[k],[k])
	end
	return covers
    removeIntersection(covers)       #rimozione delle intersezioni con se stesso
    return covers
end



"""
	intersection(line1,line2)

# Explanation

Intersect two line segments in 2D, by computing the two line parameters of the intersection point.

The line segments intersect if both return parameters `α,β` are contained in the interval `[0,1]`.

# Example

```
julia> line1 = [[0.,0], [1,2]]
2-element Array{Array{Float64,1},1}:
 [0.0, 0.0]
 [1.0, 2.0]

julia> line2 = [[2.,0], [0,3]]
2-element Array{Array{Float64,1},1}:
 [2.0, 0.0]
 [0.0, 3.0]

julia> Lar.intersection(line1,line2)
(0.8571428571428571, 0.5714285714285714)
```
"""
function intersection(line1,line2)
	x1,y1,x2,y2 = vcat(line1...)
	x3,y3,x4,y4 = vcat(line2...)

	# intersect lines e1,e2
	# http://www.cs.swan.ac.uk/~cssimon/line_intersection.html
	det = (x4-x3)*(y1-y2)-(x1-x2)*(y4-y3)
	if det != 0.0
		a = 1/det
		b = [y1-y2 x2-x1; y3-y4 x4-x3]  # x1-x2 => x2-x1 bug in the source link !!
		c = [x1-x3; y1-y3]
		(β,α) = a * b * c
	else
		if (y1==y2) == (y3==y4) || (x1==x2) == (x3==x4) # segments collinear
			 return nothing
		else
			 # segments parallel: no intersection
			 return nothing
		end
	end
	return α,β
end



"""
	linefragments(V,EV,Sigma)

# Explanation

Compute the sequences of ordered parameters fragmenting each input lines.

Extreme parameter values (`0.0` and `1.0`) are included in each output line.
`Sigma` is the spatial index providing the subset of lines whose containment boxes intersect the box of each input line (given by `EV`).

```
julia> V = hcat([[0.,0],[1,0],[1,1],[0,1],[2,1]]...);

julia> EV = [[1,2],[2,3],[3,4],[4,1],[1,5]];

julia> Sigma = Lar.spaceindex((V,EV))
5-element Array{Array{Int64,1},1}:
 [4, 5, 2]
 [1, 3, 5]
 [4, 5, 2]
 [1, 3, 5]
 [4, 1, 3, 2]

julia> Lar.linefragments(V,EV,Sigma)
5-element Array{Any,1}:
 [0.0, 1.0]
 [0.0, 0.5, 1.0]
 [0.0, 1.0]
 [0.0, 1.0]
 [0.0, 0.5, 1.0]
```
"""
function linefragments(V,EV,sigma)
    m = length(sigma) 
    sigma = map(sort,sigma) 
    params = Array{Array{Float64,1}}(undef,m)
    @threads for i=1:m
        params[i] = []
    end
    line1=[0.0 0.0; 0.0 0.0]
    line2=[0.0 0.0; 0.0 0.0]
    @threads for h=1:m
        if sigma[h] ≠ []
            line1 = V[:,EV[h]]
            @threads for k in sigma[h]
            line2 = V[:,EV[k]]
                out = intersection(line1,line2) 
                if out ≠ ()
                    if 0<=out[1]<=1 && 0<=out[2]<=1
                        push!(params[h], out[1])
                        push!(params[k], out[2])
                    end
                end
            end
        end
        end
    len = length(params)
    @threads for i=1:len
        push!(params[i], 0.0, 1.0)
        params[i] = sort(collect(Set(params[i])))
    end
    return params
end
print("Numero di threads allocati :")
println(nthreads())

"""
	fragmentlines(model::Lar.LAR)::Lar.LAR

# Explanation

Pairwise *intersection* of 2D *line segments*.

# Example 2D

```julia
V,EV = model2d
W, EW = Lar.fragmentlines(model2d) # OK
using Plasm
Plasm.viewexploded(W,EW)(1.2,1.2,1.2)
```
"""
function fragmentlines(model)
    V,EV = model
    Sigma = spaceindex(model)
    lineparams = linefragments(V,EV,Sigma)
    vertdict = OrderedDict{Array{Float64,1},Array{Int,1}}()
    pairs = collect(zip(lineparams, [V[:,e] for e in EV]))
    vertdict = OrderedDict{Array{Float64,1},Int}()
    W = Array[]
    EW = Array[]
    k = 0
    l = length(pairs)
    @inbounds for i = 1:l
        params = pairs[i][1]
        linepoints = pairs[i][2]
        v1 = linepoints[:,1] #Isolo primo punto dello spigolo
        v2 = linepoints[:,2] #Isolo secondo punto dello spigolo
        points = [ v1 + t*(v2 - v1) for t in params]   # !!!! loved !!
        vs = zeros(Int64,1,length(points))
        PRECISION = 8
        numpoint = length(points)
        @inbounds @simd for h = 1:numpoint
            points[h] = map(approxVal(PRECISION), points[h])
            if !haskey(vertdict, points[h])
                k += 1 #Genero ID punto 
                vertdict[points[h]] = k #Associo l'ID al punto
                push!(W, points[h]) #Pusho il punto(x,y) nell'array W
            end
            vs[h] = vertdict[points[h]] 
        end
        m = length(vs) - 1
        @inbounds @simd for k=1:m
            push!(EW, [vs[k], vs[k+1]])
        end
    end
    W,EW = hcat(W...),convert(Array{Array{Int64,1},1},EW)
    V,EV = congruence((W,EW))
    return V,EV
end

"""
    fraglines(sx::Float64=1.2,sy::Float64=1.2,sz::Float64=1.2)

# Explanation

It takes as input three float variables representing the Cartesian plane.
Returns a pattern that passes input to the fragmentlines function.
"""
function fraglines(sx::Float64=1.2,sy::Float64=1.2,sz::Float64=1.2)
	function fraglines0(model)
		V,EV = Lar.fragmentlines(model)

		W = zeros(Float64, size(V,1), 2*length(EV))
		EW = Array{Array{Int64,1},1}()
		for (k,(v1,v2)) in enumerate(EV)
			if size(V,1)==2
				x,y = (V[:,v1] + V[:,v2]) ./ 2
				scx,scy = x*sx, y*sy
				t = [scx-x, scy-y]
			elseif size(V,1)==3
				x,y,z = (V[:,v1] + V[:,v2]) ./ 2
				scx,scy,scz = x*sx, y*sy, z*sz
				t = [scx-x, scy-y, scz-z]
			end
			W[:,2*k-1] = V[:,v1] + t
			W[:,2*k] = V[:,v2] + t
			push!(EW, [2*k-1, 2*k])
		end
		return W,EW
	end
	return fraglines0
end



"""
	congruence(model::Lar.LAR)::Lar.LAR

# Explanation
    
Graded bases of equivalence classes Ck (Uk ), with Uk = Xk /Rk for 0 ≤ k ≤ 2.
"""
function congruence(model)
	W,EW = model
	# congruent vertices
	balltree = NearestNeighbors.BallTree(W)
	r = 0.0000000001
	near = Array{Any}(undef, size(W,2))
	for k=1:size(W,2)
		near[k] = union([NearestNeighbors.inrange(balltree, W[:,k], r, true)]...)
	end
	near = map(sort,near)  # check !!!
	for k=1:size(W,2)
		W[:,k] = W[:,near[k][1]]
	end
	pointidx = [ near[k][1] for k=1:size(W,2) ]  # check !!
	invidx = OrderedDict(zip(1:length(pointidx), pointidx))
	V = [W[:,k] for k=1:length(pointidx)]
	# congruent edges
	EV = []
	for e in (EW)
		newedge = [invidx[e[1]],invidx[e[2]]]
		if newedge[1] !== newedge[2]
			push!(EV,newedge)
		end
	end
	EV = [EV[h] for h=1:length(EV) if length(EV[h])==2]
	EV = convert(Lar.Cells, EV)
	#W,EW = Lar.simplifyCells(V,EV)
	return hcat(V...),EV
end









#=
"""
	decomposition()::

Pairwise *intersection* in ``z = 0`` of *line segments* in ``σ ∪ I(σ)``, for each ``σ ∈ Sd−1``.

# Example 3D

```julia
V,FV,EV = model3d
model = model3d

```
"""
function decomposition(model::Lar.LAR)
	V,EV = model
	dim = size(V,1)
	spatialindex = Lar.spaceindex(model)

	function submanifoldmap(vs)
		centroid = [sum(vs[k,:]) for k=1:size(vs,1)]/size(vs,2)
		# u1, u2 always independent
		u1 = normalize( centroid - vs[:,1] )
		u2 = normalize( vs[:,2] - vs[:,1] )
		u3 = normalize(cross(u1, u2))
		# u1, u2, u3 orthonormal
		u1 = cross(u2, u3)
		T = Matrix{Float64}(LinearAlgebra.I, 4, 4)
		T[1:3,4] = - vs[:,1]
		R = Matrix{Float64}(LinearAlgebra.I, 4, 4)
		R[1:3, 1:3] = [u1 u2 u3]'
		return R*T  # roto-translation matrix
	end

	for (k,Sigma) in spatialindex
		sigma = Sigma[k]
		if dim == 3
			# transform Sigma s.t. Sigma[1], i.e. sigma, -> z=0
			vs = V[:, CV[sigma]]
			Q = submanifoldmap(vs)
			vq = Q * [vs; ones(1, size(vs,2))]
			v2d = vq[1:2,:]
		end
	end

end




"""
	Connection()::
Extraction of (X p , ∂p ), maximal connected components of Xd −1 (0 ≤ p ≤ h). d−1 d−1 +p

# Example

```julia
julia>
```
"""
function Connection

end



"""
	Bases()::
Computation of redundant cycle basis [∂d ] for each p-component, via TGW.

# Example

```julia
julia>
```
"""
function Bases

end



"""
	Boundaries()::
Accumulation into H += [o]p (hole-set) of outer boundary cycle from each [∂d+]p .

# Example

```julia
julia>
```
"""
function Boundaries

end



"""
	Containment()::
Computation of antisymmetric containment relation S between [o]p holes in H.

# Example

```julia
julia>
```
"""
function Containment

end



"""
	Reduction()::
Transitive R reduction of S and generation of forest of flat trees ⟨[od ]p , [∂d ]p ⟩.

# Example

```julia
julia>
```
"""
function Reduction

end



"""
	Adjoining()::
of roots [od ]r to (unique) outer cell, and non-roots [∂d+]q to container cells.

# Example

```julia
julia>
```
"""
function Adjoining

end



"""
	Assembling()::
Quasi-block-diagonal assembly of matrices relatives to isolated components [∂d ]p .

# Example

```julia
julia>
```
"""
function Assembling

end



"""
	Output()::
Global boundary map [∂d ] of A(Sd−1), and reconstruction of 0-chains of d-cells in Xd .

# Example

```julia
julia>
```
"""
function Output

end

=#


# FUNZIONI DI SUPPORTO

"""
    removeIntersection(covers::Array{Array{Int64,1},1})

# Explanation

Eliminate the intersections contained in 'covers' that boundingboxes have with themselves

# Arguments

- `covers::Array{Array{Int64,1},1}`
"""
function removeIntersection(covers::Array{Array{Int64,1},1})
    @threads for k=1:length(covers)
        covers[k] = setdiff(covers[k],[k])	#toglie le intersezioni con se stesso 
    end
end

"""
    createIntervalTree(boxdict::AbstractDict{Array{Float64,1},Array{Int64,1}})

# Explanation

given an ordered dictionary it creates an intervalTrees that is a data structure that contains intervals
and which allows you to efficiently find all the intervals that overlap a certain interval or point.

# Arguments

- `boxdict::AbstractDict{Array{Float64,1}}`
- `boxdict::Array{Int64,1}`
"""
function createIntervalTree(boxdict::AbstractDict{Array{Float64,1},Array{Int64,1}})
    tree = IntervalTrees.IntervalMap{Float64,Array}()
    for (key, boxset) in boxdict
        tree[tuple(key...)] = boxset
    end
    return tree
end

"""
    addIntersection(covers::Array{Array{Int64,1},1}, i::Int64, iterator)
    
# Explanation

addIntersection adds all bounding boxes in 'covers' in i-th position
that intersect the i-th bounding box

# Arguments

- `covers::Array{Array{Int64,1},1}`
- `i::Int64`
- `iterator`
"""
function addIntersection(covers::Array{Array{Int64,1},1}, i::Int64, iterator)
    splice!(covers[i],1)		#splice serve a togliere gli zeri iniziali all'interno di covers
    @threads for x in collect(iterator)
        append!(covers[i],x.value)
    end
end
