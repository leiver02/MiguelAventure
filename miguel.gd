extends CharacterBody2D
signal vida_cambiada(nueva_vida)
const SPEED = 150.0

# --- REFERENCIAS A NODOS ---
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var sprite_hacha = $Mano/Hacha
@onready var area_ataque = $Mano/AreaAtaque # Tu zona para golpear

# --- VARIABLES DE ESTADO ---
var ultima_direccion = "SO"
var tiene_hacha: bool = false
var is_attacking: bool = false 
var vida_maxima: int = 3
var vida_actual: int = 3
var es_invulnerable: bool = false


func _ready() -> void:
	# Nos aseguramos de que el hacha inicie oculta o visible según el booleano
	if sprite_hacha:
		sprite_hacha.visible = tiene_hacha

func _physics_process(_delta):
	# 1. Si está atacando, bloqueamos el movimiento
	if is_attacking:
		move_and_slide() 
		return

	# 2. Lógica de Ataque (¡AHORA CON RASTREADOR DE ERRORES!)
	if Input.is_action_just_pressed("attack") and tiene_hacha:
		is_attacking = true
		velocity = Vector2.ZERO 
		
		# --- Detección con mensajes para la consola ---
		if area_ataque:
			var cuerpos_en_rango = area_ataque.get_overlapping_bodies()
			print("🪓 Atacando... Cuerpos detectados: ", cuerpos_en_rango.size())
			
			for cuerpo in cuerpos_en_rango:
				print("  -> Miguel tocó a: ", cuerpo.name)
				if cuerpo.has_method("recibir_hachazo"):
					cuerpo.recibir_hachazo()
		else:
			print("❌ ERROR: No se encontró el nodo $AreaAtaque")
		# ----------------------------------------------
		
		# Reproducimos la animación y esperamos a que termine
		animation_player.play("attack_" + ultima_direccion)
		await animation_player.animation_finished
		
		is_attacking = false 
		return

	# 3. Lógica de Movimiento
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_direction != Vector2.ZERO:
		velocity = input_direction.normalized() * SPEED
		
		if input_direction.x < 0:
			animation_player.play("walk_SO")
			ultima_direccion = "SO"
		elif input_direction.x > 0:
			animation_player.play("walk_SE")
			ultima_direccion = "SE"
		else:
			if input_direction.y < 0:
				animation_player.play("walk_SO")
				ultima_direccion = "SO"
			elif input_direction.y > 0:
				animation_player.play("walk_SE")
				ultima_direccion = "SE"
			
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		animation_player.play("idle_" + ultima_direccion)

	# 4. Actualización final por fotograma
	actualizar_posicion_hacha()
	move_and_slide()

# --- INTERACCIONES ---

func recoger_item(id_del_item: String) -> void:
	# El objeto en el piso solo debe llamar a esta función cuando lo toques
	if id_del_item == "hacha":
		tiene_hacha = true
		if sprite_hacha:
			sprite_hacha.visible = true
			
		print("🪓 ¡Miguel recogió el hacha directamente del suelo!")

func actualizar_posicion_hacha() -> void:
	# Giramos el hacha dependiendo de a dónde mire Miguel
	if not tiene_hacha or not sprite_hacha:
		return
	
	if ultima_direccion == "SO":
		sprite_hacha.flip_h = true
	else:
		sprite_hacha.flip_h = false

func recibir_dano(cantidad: int) -> void:
	if es_invulnerable:
		return

	vida_actual -= cantidad
	emit_signal("vida_cambiada", vida_actual)
	print("💔 ¡Ouch! Zanahorias restantes: ", vida_actual)
	
	if vida_actual <= 0:
		morir()
		return

	# --- INICIO DE INVULNERABILIDAD ---
	es_invulnerable = true
	sprite.modulate.a = 0.5
	
	await get_tree().create_timer(1.5).timeout
	
	# Verificamos si Miguel sigue vivo después del timer antes de restaurar su opacidad
	if is_instance_valid(self) and vida_actual > 0:
		sprite.modulate.a = 1.0
		es_invulnerable = false


func morir() -> void:
	print("💀 Miguel murió...")
	
	# 1. Desactivamos el procesamiento físico para que no pueda moverse ni atacar
	set_physics_process(false)
	set_process_unhandled_input(false)
	
	# 2. Ocultamos el personaje de inmediato
	hide()
	
	# 3. Desactivamos sus colisiones para que los enemigos no le sigan pegando
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 4. Eliminamos el nodo de la escena
	queue_free()
