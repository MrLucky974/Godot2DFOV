extends Sprite

var vel = Vector2()

func _process(delta):
	var dir = Vector2()
	
	dir.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	dir.y = -Input.get_action_strength("ui_up") + Input.get_action_strength("ui_down")
	
	dir = dir.normalized()
	vel = dir * 250
	
	global_position += vel * delta
	
	look_at(get_global_mouse_position())
