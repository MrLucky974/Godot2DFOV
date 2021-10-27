extends Node2D
class_name FieldOfView

export(bool) var debug_mode = true

export(PoolStringArray) var groups

export(float, 0, 360) var vision_angle = 120
export(float) var vision_radius = 240

onready var parent = get_parent()

var bodies := []

func get_detected_bodies() -> Array:
	"""
	Return all the Node2D objects detected by the FieldOfView.
	"""
	
	return bodies

func _ready():
	z_index = 1024

func _draw():
	"""
	For debug purposes.
	Draw the FieldOfView object on screen.
	"""
	
	if debug_mode:
		var center = to_local(parent.global_position)
		var neg = parent.rotation_degrees + (vision_angle / 2)
		var pos = parent.rotation_degrees - (vision_angle / 2)
		
		var a = angle_to_position(parent.rotation_degrees, vision_radius, center)
		var l = angle_to_position(neg, vision_radius, center)
		var r = angle_to_position(pos, vision_radius, center)
		
		var color = Color.blue if bodies.size() <= 0 else Color.green
		
		#draw_triangle(center, l*2, r*2, Color.crimson, 2.0)
		
		#draw_line(center, a, Color.red, 4.0)
		draw_line(center, l, color, 2.0)
		draw_line(center, r, color, 2.0)
		
		#draw_circle_arc(Vector2.ZERO, vision_radius, 0, 360, Color.black)
		draw_circle_arc(Vector2.ZERO, vision_radius, 90 + neg, 90 + pos, color, 2.0)

func _process(_delta):
	if debug_mode:
		rotation_degrees = -parent.rotation_degrees #To prevent _draw() to be messed up
	
	bodies.clear()
	
	for group in groups:
		for object in get_tree().get_nodes_in_group(group): #Check every object in every selected group
			if object is Node2D: #Check if the object is a 2d node (because Node and 3D won't work, obviously)
				var center = to_local(parent.global_position)
				var position = object.global_position
				
				var circle = inside_circle(vision_radius, parent.global_position, position) #Check if the object is inside the radius of the field of view
				
				var l = angle_to_position(parent.rotation_degrees + (vision_angle / 2), vision_radius, center)
				var r = angle_to_position(parent.rotation_degrees - (vision_angle / 2), vision_radius, center)
				var triangle = inside_triangle(to_local(position), center, l*2, r*2) #Check if the object is inside the triangle of the field of view
				
				if circle and triangle: #If these two conditions are met, it means the object is inside the field of view.
					var space_state =  get_world_2d().direct_space_state
					var result = space_state.intersect_ray(global_position, position, [self, parent]) #Creates a raycast to check if the object is in direct sight or behind a wall
					
					if result: #If something collide...
						if result.collider.get_parent() == object: #...and that thing is indeed the object we look for...
							if not object in bodies: #...check if this object is not already detected and add it otherwise
								bodies.append(object)
	
	update() #Update the debug

func area_of_triangle(a : Vector2, b : Vector2, c : Vector2) -> float:
	"""
	Return the area of a triangle by giving the triangle points.
	"""
	
	return abs((a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) / 2.0)

func inside_triangle(point : Vector2, a : Vector2, b : Vector2, c : Vector2) -> bool:
	"""
	Taken from : https://www.geeksforgeeks.org/check-whether-a-given-point-lies-inside-a-triangle-or-not/
	
	1) Calculate area of the given triangle, i.e., area of the triangle ABC in the above diagram.
	2) Calculate area of the triangle PAB. We can use the same formula for this. Let this area be A1.
	3) Calculate area of the triangle PBC. Let this area be A2.
	4) Calculate area of the triangle PAC. Let this area be A3.
	5) If P lies inside the triangle, then A1 + A2 + A3 must be equal to A.
	"""
	
	var A = area_of_triangle(a, b, c)
	var A1 = area_of_triangle(point, b, c)
	var A2 = area_of_triangle(a, point, c)
	var A3 = area_of_triangle(a, b, point)
	
	return true if A == (A1 + A2 + A3) else false

func inside_circle(radius : float, center : Vector2, position : Vector2) -> bool:
	"""
	Taken from : https://stackoverflow.com/questions/481144/equation-for-testing-if-a-point-is-inside-a-circle#:~:text=If%20the%20distance%20between%20them,point%20is%20outside%20the%20circle.
	"""
	
	var d = pow(radius, 2) - ( pow( (center.x - position.x) , 2) + pow( (center.y - position.y) , 2) )
	
	if (d >= 0): #If the object position is inside the circle or on the circumference, return true
		return true
	return false #The object is completely outside the circle

func angle_to_position(deg : float, radius : float = 1, center := Vector2()) -> Vector2:
	"""
	Based on trigonometry, get the position on the circle.
	"""
	
	if radius <= 0:
		print('Circle radius needs to be greater than 1.')
		return Vector2()
	
	var theta = deg2rad(deg)
	
	var x = radius * cos(theta) + center.x
	var y = radius * sin(theta) + center.y
	
	return Vector2(x, y)

func draw_triangle(a : Vector2, b : Vector2, c : Vector2, color : Color, width : float = 1.0):
	#For debug purposes
	#Ease triangle drawing
	
	draw_line(a, b, color, width)
	draw_line(b, c, color, width)
	draw_line(c, a, color, width)

func draw_circle_arc(center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color, width : float = 1.0):
	#For debug purposes
	#Taken from the official Godot wiki
	
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, width)
