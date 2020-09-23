class_name GridVertex

var v = Vector2.ZERO setget set_v
var x = 0 setget set_x
var y = 0 setget set_y
var is_outer = false
var v3 setget , get_v3

func _to_string():
	return "[" + str(round(x * 100) / 100) + ", " + str(round(y * 100) / 100) + "]"
	
func get_v3():
	return Vector3(v.x, 0, v.y)
	
func set_v(a):
	v = a
	x = v.x
	y = v.y

func set_x(a):
	x = a
	v.x = a
	
func set_y(a):
	y = a
	v.y = a

class GridVertexSorter:
	func sort_by_x(a, b):
		if a.x < b.x:
			return true
		if a.x == b.x and a.y > b.y:
			return true
		return false;
		
	func sort_by_y(a, b):
		if a.y < b.y:
			return true
		if a.y == b.y and a.x > b.x:
			return true
		return false;
