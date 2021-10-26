extends RigidBody2D

var flying = false
var clicked = false
var can_reset = false
var ground_normal = Vector2()

const RESPAWN = Vector2(487, 545)
const BOOST = 500



func _process(delta):
	
	#see if the rocket is lying, helpless, and if so then pick it up
	checkifflying()
	
	#When the user clicks, launch the rocket if its on the ground
	if Input.is_action_just_pressed("click") and not flying and abs(rotation_degrees - ground_normal.angle()*180/PI - 90) < 30:
		clicked = true
		
		#check the mouse angle
		var vector_to_mouse = get_local_mouse_position().normalized()
		vector_to_mouse.y *= 1.5
		var strength = get_local_mouse_position().length() * 2
		if vector_to_mouse.y > 0:
			vector_to_mouse.y *= -1
		
		strength = min(get_local_mouse_position().length() * 2, 1200)

		#launch the rocket (upwards only)
		apply_impulse(vector_to_mouse*-10, vector_to_mouse*strength)
		apply_torque_impulse(vector_to_mouse.x * 500)
		$CPUParticles2D.emitting = true
		$CanvasLayer/TextureProgress.value -= min(get_local_mouse_position().length() * 0.15, 100)
		$AudioStreamPlayer2D.play()
		reset_timer(2)

	if Input.is_action_just_pressed("left") and flying:
		if $CanvasLayer/TextureProgress.value >= 15:
			apply_central_impulse(Vector2(-BOOST, 0))
			$CanvasLayer/TextureProgress.value -= 15
			reset_timer(1)
		
	if Input.is_action_just_pressed("right") and flying:
		if $CanvasLayer/TextureProgress.value >= 15:
			apply_central_impulse(Vector2(BOOST,0))
			$CanvasLayer/TextureProgress.value -= 15
			reset_timer(1)
	
	if Input.is_action_just_pressed("stand_up") and can_reset:
		rotation_degrees = ground_normal.angle()*180/PI + 90
		position += ground_normal * 10
		clicked = false
		$AudioStreamPlayer2D2.play()
	
	
	if position.y > 800:
		position = RESPAWN
		rotation_degrees = 0
		angular_velocity = 0
		linear_velocity = Vector2(0,0)


	#update the progress bar(s)
	update_bar()
	
	#if the rocket is still then update the drawing function
	if not flying and abs(rotation_degrees - ground_normal.angle()*180/PI - 90) < 30:
		draw_path()
	elif abs(get_linear_velocity().length()) > 10:
		if $Line2D.get_point_count() > 0:
			$Line2D.clear_points()
	


#is the rocket moving or in the air?
func checkifflying():
	#check if the rocket is moving, if it is then flying is reset
	if get_linear_velocity().length() > 0.1 and not flying and len(get_colliding_bodies()) == 0:
		flying = true
	if get_angular_velocity() > 0.1 and not flying and len(get_colliding_bodies()) == 0:
		flying = true
		
	if abs(get_linear_velocity().length()) < 1.1 and len(get_colliding_bodies()) > 0 and abs(get_angular_velocity()) < 0.05:
		flying = false
		
	#if the rocket is not moving, was moving before, is touching ground, and is not already upright, then put the rocket upright
	if not flying:
		$RayCast2D.global_rotation = 0
		ground_normal = $RayCast2D.get_collision_normal()
		if abs(rotation_degrees - ground_normal.angle()*180/PI - 90) > 20:
			#rotation_degrees = ground_normal.angle()*180/PI + 90
			#position += ground_normal * 10
			#clicked = false
			can_reset = true
			$CanvasLayer/StandUpPrompt.show()
			#$ResetTimer.start(2)
		else:
			can_reset = false
			$CanvasLayer/StandUpPrompt.hide()
	else:
		can_reset = false
		$CanvasLayer/StandUpPrompt.hide()


func draw_path():
	$Line2D.clear_points()
	var starting_point = Vector2(0,0)
	var mouse_position = get_local_mouse_position()
	if mouse_position.y > 0:
		mouse_position.y *= -1
	var angle = mouse_position.angle() + PI/2
	var direction = Vector2(cos(angle), sin(angle))
	var length = get_local_mouse_position().length()/5
	var points = 10
	var change_in_angle = angle/points - PI/2

	for _x in range (0, points):
		direction = Vector2(cos(change_in_angle), sin(change_in_angle))
		starting_point += direction*(length/points)
		$Line2D.add_point(starting_point)
		change_in_angle += angle/points

func update_bar():
	if not flying:
		$CanvasLayer/TextureProgress2.value = min(get_local_mouse_position().length() * 0.15, $CanvasLayer/TextureProgress.value)
	else:
		$CanvasLayer/TextureProgress2.value = lerp($CanvasLayer/TextureProgress2.value, 0, 0.2)
	
	if $CanvasLayer/TextureProgress.value < 100 and $RechargeTimer.is_stopped():
		$CanvasLayer/TextureProgress.value += 1

func reset_timer(value):
	if $RechargeTimer.is_stopped():
		$RechargeTimer.start(value)
	else:
		$RechargeTimer.start($RechargeTimer.get_time_left() + value)

