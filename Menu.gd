extends CanvasLayer

var startorpause = 1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Node2D/Victory").hide()
	$StartMenu.show()
	$PauseMenu.hide()
	$Pause.hide()
	$ControlMenu.hide()
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("escape") and not $StartMenu.is_visible():
		if not $PauseMenu.is_visible():
			get_tree().paused = true
			$PauseMenu.show()
		else:
			get_tree().paused = false
			$PauseMenu.hide()
	
		


func _on_Pause_pressed():
	startorpause = 2
	get_tree().paused = true
	$PauseMenu.show()


func _on_Controls_pressed():
	$ControlMenu.show()
	$PauseMenu.hide()


func _on_Resume_pressed():
	get_tree().paused = false
	$PauseMenu.hide()


func _on_Start_pressed():
	get_tree().paused = false
	$StartMenu.hide()
	$Pause.show()


func _on_Restart_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false


func _on_Back_pressed():
	if startorpause == 1:	
		$StartMenu.show()
	else:
		$PauseMenu.show()
	$ControlMenu.hide()


func _on_Start_Controls_pressed():
	$ControlMenu.show()
	$StartMenu.hide()



func _on_Area2D_body_entered(body):
	get_node("/root/Node2D/Victory").show()
	print("done")
