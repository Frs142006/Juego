extends CharacterBody2D

@onready var animacion = $Animaciones
@onready var ataqueArea = $AtaqueArea/AtaqueCollision
@onready var objeto1 = $Camara/Objeto1
@onready var objeto2 = $Camara/Objeto2
@onready var objeto3 = $Camara/Objeto3
@onready var salud = $Camara/Vida
@onready var escudos = $Camara/Escudo
@onready var cabeza = $Camara/Cabeza
@onready var monedas = $Camara/Monedas
@onready var moneda = $Camara/Moneda
@onready var sonido = $Punch

const SPEED = 300.0
const trucoGhost:Array =  ["Izquierda", "Derecha","Derecha","Ataque","Izquierda","Ataque"]
var trucoVerificar:Array = []
var contador:int = 0
var JUMP_VELOCITY = -500.0
var objetos:Array = []
var espada: bool = false
var armadura: bool = false
var globo: bool = false
var vida: int = 10
var escudo: int = 0
var usosEspada: int = 0

var puedeSubir: bool = false
var personajeMuerto: bool = false
var salto: bool = false
var enemigos_en_contacto = []  # Lista para almacenar los enemigos en contacto
var objetoAsginado1 = null
var objetoAsginado2 = null
var objetoAsginado3 = null
var seleccion:bool = false
var vidaAnterior:int = 10
var escudoAnterior:int = 5
var yisus:bool = false
var skin:String = ""
var skinAnterior:String = "nada"


func _ready() -> void:
	cabeza.play("default")
	animacion.play("default")
	
func _physics_process(delta: float) -> void:

	if skin != skinAnterior:
		skinAnterior = skin
		cabeza.play("default"+ skin)
	else:
		if armadura:
				cabeza.play("defaultArmadura"+ skin)
		
	if Input.is_action_just_pressed("Cambiar") and yisus == false:
		if yisus == false:
			yisus = true
			skin= "Yisus"
		cabeza.play("default"+ skin)			
	elif Input.is_action_just_pressed("Cambiar") and yisus == true :
		yisus = false
		skin = ""
		cabeza.play("default"+ skin)	
		
	monedas.text = str(contador)
	moneda.play("default")
	
	if globo:
		JUMP_VELOCITY = -650.0
	else:
		JUMP_VELOCITY = -500.0
		
	if vidaAnterior != vida and escudo == 0:
		vidaAnterior = vida
		await get_tree().create_timer(0.15).timeout  # Esperar 0.5 segundos # Esperar 0.5 segundos
		cabeza.play("ouch" + skin)
		await get_tree().create_timer(0.15).timeout  # Esperar 0.5 segundos # Esperar 0.5 segundos
		cabeza.play("default"+ skin)
	elif escudoAnterior!= escudo and escudo != 0 :
		escudoAnterior = escudo
		await get_tree().create_timer(0.15).timeout  # Esperar 0.5 segundos # Esperar 0.5 segundos
		cabeza.play("ouchArmadura"+skin)
		await get_tree().create_timer(0.15).timeout  # Esperar 0.5 segundos # Esperar 0.5 segundos
		cabeza.play("defaultArmadura"+skin)
		
	if escudo  <= 0 :
		armadura = false
		
		
	
	objeto1.z_index = 1
	objeto2.z_index = 1
	objeto3.z_index = 1
	salud.z_index = 1
	escudos.z_index = 1
	cabeza.z_index = 1
	moneda.z_index = 1
	monedas.z_index = 1
	if skin != "Ghost":
		truco()
	vidas()
	inventario()
	if vida > 0:
	
		if puedeSubir:
			if Input.is_action_pressed("Arriba"):
				if Input.is_action_pressed("Correr"):
					velocity.y = -SPEED * 2  # Movimiento rápido hacia arriba
				else:
					velocity.y = -SPEED  # Movimiento normal hacia arriba
			elif Input.is_action_pressed("Abajo"):
				if Input.is_action_pressed("Correr"):
					velocity.y = SPEED * 2  # Movimiento rápido hacia abajo
				else:
					velocity.y = SPEED  # Movimiento normal hacia abajo
			else:
				# Si no se presiona ninguna tecla, mantener posición en la escalera
				velocity.y = 0
		else:
			velocity += get_gravity() * delta

		if Input.is_action_just_pressed("Salto") and salto == false:
			salto = true
			velocity.y = JUMP_VELOCITY
		elif is_on_floor() and salto == true:
			salto = false
			
		var direction := Input.get_axis("Izquierda", "Derecha")
		if direction:
			if espada and armadura and is_on_floor():
				animacion.play("moveEspada_Armadura"+skin)
			elif espada and is_on_floor():
				animacion.play("moveEspada"+skin)
			elif armadura and is_on_floor():
				animacion.play("moveArmadura"+skin)
			elif is_on_floor():
				animacion.play("move"+skin)

			if direction == -1:
				animacion.flip_h = true
				ataqueArea.position = Vector2(-20, 5)
			else:
				animacion.flip_h = false
				ataqueArea.position = Vector2(20, 5)

			if Input.is_action_pressed("Correr") and is_on_floor():
				velocity.x = direction * SPEED * 2
			else:
				velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if espada and armadura:
				animacion.play("defaultEspada_Armadura"+skin)
			elif espada:
				animacion.play("defaultEspada"+skin)
			elif armadura and globo:
				animacion.play("flyArmadura"+skin)
			elif armadura:
				animacion.play("defaultArmadura"+skin)
			elif globo:
				animacion.play("fly"+skin)
			else:
				animacion.play("default"+skin)
		
		# Procesar ataque y eliminar enemigos en contacto
		if Input.is_action_just_pressed("Ataque") and espada:
			sonido.play()
			for enemigo in enemigos_en_contacto:
				enemigo.queue_free()
			enemigos_en_contacto.clear()  # Limpiar la lista después de eliminar enemigos

		move_and_slide()
	else:
		queue_free()
		personajeMuerto = true

func _on_ataque_area_body_entered(body: Node2D) -> void:
	if body.name == "Espada":
		body.queue_free()
		objetos.append("Espada")
		
	elif body.is_in_group("monedas"):
		body.queue_free()
		contador+=1
	elif body.name == "Botiquin":
		body.queue_free()
		if (vida + 2) < 10:
			vida+=2
		else:
			vida = 10
		
	elif body.is_in_group("armaduras"):
		body.queue_free()
		objetos.append("Armadura")
		
	elif body.name == "Globo":
		body.queue_free()
		objetos.append("Globo")
		
	elif body.is_in_group("enemigos") and espada:
		# Añadir el enemigo a la lista si entra en la zona de ataque
		enemigos_en_contacto.append(body)
		

func _on_ataque_area_body_exited(body: Node2D) -> void:
	# Eliminar el enemigo de la lista si sale de la zona de ataque
	if body in enemigos_en_contacto:
		enemigos_en_contacto.erase(body)


func _on_escalera_body_entered(body: Node2D) -> void:
	if body.name == "Personaje":
		puedeSubir = true

func _on_escalera_body_exited(body: Node2D) -> void:
	puedeSubir = false

func _on_area_caida_body_entered(body: Node2D) -> void:
	body.queue_free()
	personajeMuerto = true

func inventario() -> void:
	
	if objetos.size() == 0:
		objeto1.play("Default")
		objeto2.play("Default")
		objeto3.play("Default")
		return  # Salir de la función si no hay objetos

	# Asignar objetos solo si están disponibles y no han sido asignados
	if objetoAsginado1 == null and objetos.size() > 0:
		objetoAsginado1 = objetos[0]  
		objeto1.play(objetoAsginado1)
		
	if objetoAsginado2 == null and objetos.size() > 1:
		objetoAsginado2 = objetos[1]  
		objeto2.play(objetoAsginado2)  
		
	if objetoAsginado3 == null and objetos.size() > 2:
		objetoAsginado3 = objetos[2]  
		objeto3.play(objetoAsginado3)  

	# Reproducir la animación seleccionada si se presiona la tecla correspondiente
	if Input.is_action_just_pressed("Objeto1") and objetoAsginado1 != null:
		seleccion = true
		objeto2.play(str(objetoAsginado2) if objetoAsginado2 != null else "Default")
		objeto3.play(str(objetoAsginado3) if objetoAsginado3 != null else "Default")
		objeto1.play(str(objetoAsginado1) + "Select")
		
		# Activar el objeto seleccionado
		activar_objeto(objetoAsginado1)
		if objetoAsginado1 == "Armadura":
			objetos.erase(objetoAsginado1)
			reorganizar_inventario()
			objetoAsginado1 = null

	elif Input.is_action_just_pressed("Objeto2") and objetoAsginado2 != null:
		seleccion = true
		objeto1.play(str(objetoAsginado1) if objetoAsginado1 != null else "Default")
		objeto3.play(str(objetoAsginado3) if objetoAsginado3 != null else "Default")
		objeto2.play(str(objetoAsginado2) + "Select")
		
		activar_objeto(objetoAsginado2)
		if objetoAsginado2 == "Armadura":
			objetos.erase(objetoAsginado2)
			reorganizar_inventario()
			objetoAsginado2 = null

	elif Input.is_action_just_pressed("Objeto3") and objetoAsginado3 != null:
		seleccion = true
		objeto1.play(str(objetoAsginado1) if objetoAsginado1 != null else "Default")
		objeto2.play(str(objetoAsginado2) if objetoAsginado2 != null else "Default")
		objeto3.play(str(objetoAsginado3) + "Select")
		
		activar_objeto(objetoAsginado3)
		if objetoAsginado3 == "Armadura":
			objetos.erase(objetoAsginado3)
			reorganizar_inventario()
			objetoAsginado3 = null

# Nueva función para activar el objeto seleccionado
func activar_objeto(nombre_objeto: String) -> void:
	match nombre_objeto:
		"Espada":
			espada = true
			globo = false
		"Armadura":
			espada = false
			armadura = true
			globo = false
			escudo = 5
			cabeza.play("defaultArmadura"+skin)
		"Globo":
			espada = false
			globo = true

# Nueva función para reorganizar el inventario
func reorganizar_inventario() -> void:
	# Reasignar objetos
	objetoAsginado1 = null
	objetoAsginado2 = null
	objetoAsginado3 = null
	
	if objetos.size() > 0:
		objetoAsginado1 = objetos[0]
		objeto1.play(objetoAsginado1)
	
	if objetos.size() > 1:
		objetoAsginado2 = objetos[1]
		objeto2.play(objetoAsginado2)

	if objetos.size() > 2:
		objetoAsginado3 = objetos[2]
		objeto3.play(objetoAsginado3)

	# Reproducir animaciones para objetos que se han asignado
	if objetoAsginado1 == null:
		objeto1.play("Default")
	if objetoAsginado2 == null:
		objeto2.play("Default")
	if objetoAsginado3 == null:
		objeto3.play("Default")


func vidas()-> void:
	escudos.play("Escudo" +str(escudo))
	salud.play("Vida" +str(vida))
	

func truco():
	
	var action = ""
	if Input.is_action_just_pressed("Izquierda"):
		action = "Izquierda"
	elif Input.is_action_just_pressed("Derecha"):
		action = "Derecha"
	elif Input.is_action_just_pressed("Ataque"):
		action = "Ataque"
		
	if action != "":
		# Agrega la acción a la lista de verificaciones
		trucoVerificar.append(action)
	
	for i in range(trucoVerificar.size()):
		if trucoVerificar[i] == trucoGhost[i]:
			pass
		else:
			trucoVerificar.clear()
			
		if trucoVerificar == trucoGhost:
			skin ="Ghost"
			trucoVerificar.clear()
			return skin
