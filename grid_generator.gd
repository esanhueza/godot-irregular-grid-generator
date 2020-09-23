class_name IrregularHexGridGenerator

var rings = 5
var radius = 5
var relax_iterations = 30
var nseed = 1

func generate():
	var points = generate_points(rings, radius)
	var triangles = generate_triangles(points)
	
	randomize()
	var n_preserved_triangles = floor(randf() * triangles.size() * 0.3)
	var preserved_triangles = []
	for i in range(n_preserved_triangles):
		var index = randi() % triangles.size()
		preserved_triangles.append(triangles[index])
		triangles.remove(index)
	
	var result = generate_quads(triangles)
	var quads = result[0]
	triangles = result[1]
	
	quads = subdivide(quads + preserved_triangles + triangles)
	merge_vertices(quads)
	
	for i in range(relax_iterations):
		relax(quads)
	return quads

func relax(quads):
	var acc_area = 0
	for p in quads:
		acc_area += p.get_area_squared()
	var hd = sqrt(acc_area / quads.size()) / 2
	
	var forces = {}
	for p in quads:
		var variations = p.calc(hd)
		for variation in variations:
			if not forces.has(str(variation[0])):
				forces[str(variation[0])] = [variation[0], Vector2.ZERO]
			forces[str(variation[0])][1] += variation[1]
	
	for variation in forces.values():
		if not variation[0].is_outer:
			variation[0].v += variation[1] * 0.4
	
func merge_vertices(quads):
	var vertices = {}
	for p in quads:
		for i in range(4):
			if not vertices.has(str(p.get(i))):
				vertices[str(p.get(i))] = p.get(i)
			else:
				p.set(i, vertices[str(p.get(i))])
	
func subdivide(faces):
	var quads = []
	for p in faces:
		if p != null:
			quads += p.subdivide()
	return quads

func generate_points(rings, radius):
	var points = []
	var sin60 = sin(PI/3)
	var inv_tag60 = 1/tan(PI/3)
	var rds = radius*1.0/rings
	for col_index in range(-rings, rings + 1):
		var x = sin60 * rds * col_index
		var col_points_count = (2 * rings + 1) - abs(col_index)
		var row_min = -rings
		
		if col_index < 0:
			row_min += abs(col_index)
			
		var row_max = row_min + col_points_count
		
		for row_index in range(row_min, row_max):
			var z = (inv_tag60 * x) + rds * row_index
			var gv = GridVertex.new()
			
			gv.is_outer = (col_index == -rings or 
				col_index == rings or
				row_index == row_max - 1or
				row_index == row_min
			)
			
			gv.v = Vector2(x, z)
			points.append(gv)
	return points


func generate_triangles(points):
	var triangles = []
	var base = 0
	for col_index in range(-rings, rings):
		for row_index in range(2*rings+1-abs(col_index) - 1):
			var a = base + row_index
			var b = a + 1
			var c = base + row_index + 2*rings+1-abs(col_index)
			if col_index < 0:
				c += 1
			
			var t = Triangle.new()
			t.a = points[a]
			t.c = points[b]
			t.b = points[c]
			t.calculate_centroid()
			triangles.append(t)
		base += 2*rings+1-abs(col_index)
				
	base = 0
	for col_index in range(-rings + 1, rings + 1):
		base += 2*rings-abs(col_index - 1) + 1
		for row_index in range(0, 2*rings-abs(col_index)):
			var a = base + row_index
			var b = a + 1
			var c = a - (2*rings-abs(col_index))
			
			if col_index > 0:
				c -= 1
			
			var t = Triangle.new()
			t.a = points[a]
			t.c = points[b]
			t.b = points[c]
			t.calculate_centroid()
			triangles.append(t)
	return triangles

func generate_quads(triangles):
	var quads = []
			
	for i in range(triangles.size()):
		if triangles[i] == null:
			continue
			
		var adyacents = []
		for j in range(triangles.size()):
			if triangles[j] == null:
				continue

			if triangles[i].is_adyacent(triangles[j]):
				adyacents.append(j)

		if adyacents.size() > 0:
			var adyacent_index = adyacents[randi() % adyacents.size()]
			var q = Quad.new_from_triangles(Quad.new(), triangles[i], triangles[adyacent_index])
			quads.append(q)
			triangles[i] = null
			triangles[adyacent_index] = null
	
	var i = 0
	while i < triangles.size():
		if triangles[i] == null:
			triangles.remove(i)
			i-=1
		i+=1
	
	# returns the new quads along with the triangles that weren't merged
	return [quads, triangles]

