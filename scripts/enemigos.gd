extends CharacterBody2D

@onready var ataqueArea = $AtaqueArea/AtaqueCollision
@onready var animacion = $Animaciones
@onready var sonido = $Punch
# Variables para la velocidad y dirección de movimiento
var speed: float = 100.0
var direction: int = 1  # 1 para derecha, -1 para izquierda
var dentroDeArea:bool = false
var jugador:Node2D = null
# Método que se llama en cada frame
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Establecer la velocidad en función de la dirección
	velocity.x = speed * direction
	animacion.play("move")
	
	if dentroDeArea == true:
		if direction == 1 :
			direction = -1
			
			animacion.flip_h = true
		else:
			direction = 1
			
			animacion.flip_h = false
		dentroDeArea = false
	# Mover al enemigo
	move_and_slide()

# Método que se llama cuando el área de ataque detecta un cuerpo
func _on_ataque_area_body_entered(body: Node2D) -> void:
		dentroDeArea = true
		
		jugador = body
		
		if jugador.name == "Personaje"and jugador.vida >0 and jugador.escudo <= 0:
			sonido.play()
			jugador.vida-=1
		elif  jugador.name == "Personaje"and jugador.vida >0 and jugador.escudo > 0:
			jugador.escudo-=1
			
func _on_ataque_area_body_exited(body: Node2D) -> void:
	dentroDeArea = false
	jugador = null
