extends CharacterBody2D

const SPEED = 110.0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

# Esta variable recordará hacia dónde miraba el vaquero por última vez
var ultima_direccion = "SO"

func _physics_process(_delta):
	# 1. Recibir los comandos del teclado usando el Input Map
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_direction != Vector2.ZERO:
		# 2. Convertir el movimiento lineal a los ejes inclinados de la perspectiva isométrica
		var iso_direction = Vector2.ZERO
		iso_direction.x = input_direction.x - input_direction.y
		iso_direction.y = (input_direction.x + input_direction.y) / 2
		
		# Aplicamos la velocidad física
		velocity = iso_direction.normalized() * SPEED
		
		# 3. Decidir qué animación de caminata usar según hacia dónde camina en la pantalla
		# Si se mueve hacia la izquierda en la pantalla, es Suroeste (SO)
		if velocity.x < 0:
			animation_player.play("walk_SO")
			ultima_direccion = "SO"
		# Si se mueve hacia la derecha en la pantalla, es Sureste (SE)
		elif velocity.x > 0:
			animation_player.play("walk_SE")
			ultima_direccion = "SE"
			
	else:
		# Frenar suavemente si no se toca ninguna tecla
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
		# 4. Cuando se detiene, poner la animación estática (Idle) correspondiente
		animation_player.play("idle_" + ultima_direccion)

	# Mueve físicamente al vaquero respetando colisiones
	move_and_slide()
