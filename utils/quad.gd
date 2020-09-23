class_name Quad

const GridVertex = preload("grid_vertex.gd")

var a
var b
var c
var d
var centroid = GridVertex.new()

static func new_from_triangles(q, t1, t2):
	var vertices = {}
	for v in [t1.a,t1.b,t1.c,t2.a,t2.b,t2.c]:
		vertices[str(v)] = v
	
	var values = vertices.values()
	q.a = values[0]
	q.b = values[1]
	q.c = values[2]
	q.d = values[3]
	q.calculate_centroid()
	q.sort_vertices()
	return q

func to_mesh(height=1):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mesh = Mesh.new()
	for v in [a.v3, b.v3, c.v3, a.v3, c.v3, d.v3]:
		st.add_vertex(v + Vector3.UP * height)
	
	for v in [a.v3, c.v3, b.v3, a.v3, d.v3, c.v3]:
		st.add_vertex(v)
	
	for i in range(4):
		st.add_vertex(get(i).v3)
		st.add_vertex(get(i).v3 + Vector3.UP * height)
		st.add_vertex(get(i-1).v3 + Vector3.UP * height)
		
		st.add_vertex(get(i).v3)
		st.add_vertex(get(i+1).v3)
		st.add_vertex(get(i).v3 + Vector3.UP * height)
	
	st.index()
	st.generate_normals()
	st.commit(mesh)
	return mesh

func to_pool_vector2_array():
	return PoolVector2Array([a.v*1.3, b.v*1.3, c.v*1.3, d.v*1.3])

func _to_string():
	return "[" + str(a) + ", " + str(b) + ", " + str(c) + ", " + str(d) + "]"
	
func get(index):
	return [a,b,c,d][index%4]

func set(index, vertex):
	if index == 0:
		a = vertex
	elif index == 1:
		b = vertex
	elif index == 2:
		c = vertex
	elif index == 3:
		d = vertex
		
func calculate_centroid():
	centroid.x = (a.x + b.x + c.x + d.x)/4
	centroid.y = (a.y + b.y + c.y + d.y)/4
		
func sort_vertices():
	var sorter = VertexSorter.new()
	sorter.centroid = centroid
	var vertices = [a,b,c,d]
	vertices.sort_custom(sorter, "sort")
	a = vertices[0]
	b = vertices[1]
	c = vertices[2]
	d = vertices[3]
	
func get_class():
	return "Quad"

func subdivide():
	var quads = []
	if not centroid:
		calculate_centroid()
	for set in [[a,b,c], [b,c,d], [c,d,a], [d,a,b]]:
		var q = get_script().new()
		q.a = set[1]
		q.b = centroid
		var cv = GridVertex.new()
		var dv = GridVertex.new()
		cv.v = (set[0].v - set[1].v) / 2 + set[1].v
		dv.v = (set[2].v - set[1].v) / 2 + set[1].v
		cv.is_outer = set[0].is_outer and set[1].is_outer
		dv.is_outer = set[2].is_outer and set[1].is_outer
		q.c = cv
		q.d = dv
		q.calculate_centroid()
		q.sort_vertices()
		quads.append(q)
	return quads

func calc(hd):
	calculate_centroid()
	var squares = []
	for i in range(4):
		var dir = centroid.v.direction_to(get(i).v).normalized()
		squares.append([
			centroid.v + dir * hd/2,
			centroid.v + (dir * hd/2).rotated(PI/2),
			centroid.v + (dir * hd/2).rotated(PI),
			centroid.v + (dir * hd/2).rotated(270*PI/180),
		])
	
	var lowest_distance = 99999999
	var best_square_index = 0
	var forces = []
	for i in range(4):
		var square = squares[i]
		var distance = 0
		var pforces = []
		for j in range(4):
			var d = square[j].distance_squared_to(get(j).v)
			pforces.append(d)
		if distance < lowest_distance:
			forces = pforces
			lowest_distance = distance
			best_square_index = i
	return [
		[get(0), forces[0] * get(0).v.direction_to(squares[0][0]).normalized()],
		[get(1), forces[1] * get(1).v.direction_to(squares[1][1]).normalized()],
		[get(2), forces[2] * get(2).v.direction_to(squares[2][2]).normalized()],
		[get(3), forces[3] * get(3).v.direction_to(squares[3][3]).normalized()]
	]

func calc_dev(hd):
	calculate_centroid()
	var squares = []
	for i in range(4):
		var dir = (get(i).v - centroid.v).normalized()
		squares.append([
			centroid.v + dir * hd,
			centroid.v + (dir * hd).rotated(PI/2),
			centroid.v + (dir * hd).rotated(PI),
			centroid.v + (dir * hd).rotated(270*PI/180),
		])
	var lowest_distance = 1000
	var best_square_index = 0
	for i in range(4):
		var square = squares[i]
		var distance = 0
		for j in range(4):
			distance += square[j].distance_to(get(j).v)
		
		if distance < lowest_distance:
			lowest_distance = distance
			best_square_index = i
	var q = get_script().new()
	q.a = squares[best_square_index][0]
	q.b = squares[best_square_index][1]
	q.c = squares[best_square_index][2]
	q.d = squares[best_square_index][3]
	return q
		
		
func get_area_squared():
	return (a.v.distance_squared_to(c.v) * centroid.v.distance_squared_to(b.v) + a.v.distance_squared_to(c.v) * centroid.v.distance_squared_to(d.v)) / 2

class VertexSorter:
	var centroid
	func sort(a, b):
		var angle1 = atan2(a.y - centroid.y, a.x - centroid.x)
		var angle2 = atan2(b.y - centroid.y, b.x - centroid.x)
		if angle1 < angle2:
			return true;
		elif (angle2 < angle1): 
			return false;
		return false;
