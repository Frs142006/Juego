extends StaticBody2D

@onready var animacion = $SpriteMoneda

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animacion.play("default")
