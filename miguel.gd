extends CharacterBody2D

# 1. Definición de variables globales del personaje
const SPEED = 150.0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

# Esta variable recordará hacia dónde miraba el vaquero por última vez
var ultima_direccion = "SO"

# 2. Función principal de física y movimiento
func _physics_process(_delta):
	# Recibir los comandos del teclado directamente
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_direction != Vector2.ZERO:
		# Movimiento directo sin ejes isométricos
		velocity = input_direction.normalized() * SPEED
		
		# Control de animaciones (Prioridad Horizontal para diagonales)
		if input_direction.x < 0:
			# Si va a la izquierda (o arriba-izquierda / abajo-izquierda)
			animation_player.play("walk_SO")
			ultima_direccion = "SO"
		elif input_direction.x > 0:
			# Si va a la derecha (o arriba-derecha / abajo-derecha)
			animation_player.play("walk_SE")
			ultima_direccion = "SE"
		else:
			# Movimiento vertical puro (cuando X es 0)
			if input_direction.y < 0:
				# Arriba puro
				animation_player.play("walk_SO")
				ultima_direccion = "SO"
			elif input_direction.y > 0:
				# Abajo puro
				animation_player.play("walk_SE")
				ultima_direccion = "SE"
			
	else:
		# Frenar si sueltas las teclas
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
		# Mantener la pose quieta correcta
		animation_player.play("idle_" + ultima_direccion)

	# Aplicar el movimiento físico
	move_and_slide()
