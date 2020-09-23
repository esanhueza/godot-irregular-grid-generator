
const Quad = preload("quad.gd")
const GridVertex = preload("grid_vertex.gd")

class_name Triangle

var a
var b
var c
var centroid = GridVertex.new()

func generate_quads():
	var quads = []
	var t = self
	for set in [[t.a, t.b, t.c], [t.b, t.c, t.a], [t.c, t.a, t.b]]:
		var q = Quad.new()
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
	
func _to_string():
	return "[" + str(a) + ", " + str(b) + ", " + str(c) + "]"

func is_adyacent(t):
	var overlapping = 0
	for v1 in [a, b, c]:
		for v2 in [t.a,t.b,t.c]:
			if (v1.x == v2.x and v1.y == v2.y):
				overlapping += 1
	
	return overlapping == 2
	
func calculate_centroid():
	var x = 0
	var y = 0
	for v in [a,b,c]:
		x += v.x
		y += v.y
	centroid.v = Vector2(x / 3, y / 3)
	
func subdivide():
	if not centroid:
		calculate_centroid()
	return generate_quads()

func get_class():
	return "Triangle"
