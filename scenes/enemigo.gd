extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D

var velocidad: float = 60.0
var jugador: Node2D = null

func _ready() -> void:
	anim.play("caminar")
	jugador = get_tree().current_scene.get_node_or_null("Node2D/CharacterBody2D")
	
	# Añade estas líneas para investigar:
	if jugador:
		print("🔍 El enemigo persigue a: ", jugador.name, " en la posición: ", jugador.global_position)
		print("📍 Posición de Miguel visualmente debería ser distinta si está mal el centro.")

func _physics_process(_delta: float) -> void:
	# Si el jugador existe en el mapa, procedemos a cazarlo
	if jugador:
		# 1. Calculamos hacia dónde ir (Posición de Miguel - Mi Posición)
		var direccion = (jugador.global_position - global_position).normalized()
		
		# 2. Aplicamos el movimiento
		velocity = direccion * velocidad
		move_and_slide()
		
		# 3. Volteamos el sprite para que mire hacia donde camina
		if direccion.x < 0:
			sprite.flip_h = true  # Mira a la izquierda
		else:
			sprite.flip_h = false # Mira a la derecha

# --- INTERACCIONES ---

func _on_zona_de_golpe_body_entered(body: Node2D) -> void:
	if body.has_method("recibir_dano"):
		body.recibir_dano(1)
		
		# --- NUEVO: Evitar el efecto excavadora ---
		# Guardamos su velocidad original y lo detenemos
		var velocidad_original = velocidad
		velocidad = 0.0 
		
		# Esperamos 1 segundo (mientras Miguel es invulnerable)
		await get_tree().create_timer(1.0).timeout
		
		# El monstruo vuelve a perseguirte
		velocidad = velocidad_original

func recibir_hachazo() -> void:
	print("💀 ¡El enemigo recibió un hachazo!")
	# Aquí eliminamos al monstruo del mapa
	queue_free()
