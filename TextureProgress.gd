extends TextureProgress

func _ready():
	pass # Replace with function body.


func _process(delta):
	if value < 100:
		value += 0.1
