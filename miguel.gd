extends CharacterBody2D

signal vida_cambiada(nueva_vida)
const SPEED = 150.0

# --- PRECARGA DE LA PANTALLA DE MUERTE ---
# Asegúrate de ajustar esta ruta al lugar exacto donde guardaste tu escena
const PANTALLA_MUERTE = preload("res://scenes/PantallaMuerte.tscn")

# --- REFERENCIAS A NODOS ---
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var sprite_hacha = $Mano/Hacha
@onready var area_ataque = $Mano/AreaAtaque

# --- VARIABLES DE ESTADO ---
var ultima_direccion = "SO"
var tiene_hacha: bool = false
var is_attacking: bool = false 
var vida_maxima: int = 3
var vida_actual: int = 3
var es_invulnerable: bool = false


func _ready() -> void:
	if sprite_hacha:
		sprite_hacha.visible = tiene_hacha


func _physics_process(_delta):
	# 1. Si está atacando, bloqueamos el movimiento
	if is_attacking:
		move_and_slide() 
		return

	# 2. Lógica de Ataque
	if Input.is_action_just_pressed("attack") and tiene_hacha:
		is_attacking = true
		velocity = Vector2.ZERO 
		
		if area_ataque:
			var cuerpos_en_rango = area_ataque.get_overlapping_bodies()
			print("🪓 Atacando... Cuerpos detectados: ", cuerpos_en_rango.size())
			
			for cuerpo in cuerpos_en_rango:
				print("  -> Miguel tocó a: ", cuerpo.name)
				if cuerpo.has_method("recibir_hachazo"):
					cuerpo.recibir_hachazo()
		else:
			print("❌ ERROR: No se encontró el nodo $AreaAtaque")
		
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

	actualizar_posicion_hacha()
	move_and_slide()


# --- INTERACCIONES ---

func recoger_item(id_del_item: String) -> void:
	if id_del_item == "hacha":
		tiene_hacha = true
		if sprite_hacha:
			sprite_hacha.visible = true
			
		print("🪓 ¡Miguel recogió el hacha!")


func actualizar_posicion_hacha() -> void:
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
	
	if is_instance_valid(self) and vida_actual > 0:
		sprite.modulate.a = 1.0
		es_invulnerable = false


func morir() -> void:
	print("💀 Miguel murió...")
	
	# 1. Instanciar y agregar la pantalla de muerte
	var pantalla = PANTALLA_MUERTE.instantiate()
	get_tree().root.add_child(pantalla)
	
	# 2. Desactivar físicas, controles y visibilidad de Miguel
	set_physics_process(false)
	set_process_unhandled_input(false)
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 3. Congelar el juego
	get_tree().paused = true
	
	# 4. Eliminar el nodo de Miguel
	queue_free()
