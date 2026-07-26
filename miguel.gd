extends CharacterBody2D

const SPEED = 150.0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var sprite_hacha = $Mano/Hacha
@onready var inventario_ui =  $"../../CanvasLayer/PlayerInventory"
@onready var equipamiento_ui = $"../../CanvasLayer/PlayerEquipment"

var ultima_direccion = "SO"
var tiene_hacha: bool = false
var is_attacking: bool = false 


func _ready() -> void:
	if sprite_hacha:
		sprite_hacha.visible = tiene_hacha
	if inventario_ui and equipamiento_ui:
		inventario_ui.visible = false
		#equipamiento_ui.visible = false

	# LA MAGIA: Esperamos 1 frame para garantizar que todos los inventarios ya cargaron
	await get_tree().process_frame

	# --- EL BYPASS: Usamos tu propia variable en lugar de InventorySystem ---
	if equipamiento_ui:
		print("🟢 ÉXITO: Miguel se conectó directo al nodo PlayerEquipment.")
		equipamiento_ui.item_equipped.connect(_on_item_equipped)
		equipamiento_ui.item_unequipped.connect(_on_item_unequipped)
	else:
		print("🔴 ERROR FATAL: La ruta de equipamiento_ui está mal.")
	# -------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventario"):
		if inventario_ui and equipamiento_ui:
			inventario_ui.visible = not inventario_ui.visible
			equipamiento_ui.visible = not equipamiento_ui.visible
			equipamiento_ui.visible = inventario_ui.visible


func _on_item_equipped(item) -> void:
	print("🛠️ SEÑAL RECIBIDA: Intentando equipar el ítem -> ", item.name)
	
	# Cambiamos item.id por item.name
	if item.name == "hacha": 
		tiene_hacha = true
		sprite_hacha.visible = true
		print("🪓 ¡Hacha visible en la mano de Miguel!")


# Adaptado a 1 solo parámetro (Item)
func _on_item_unequipped(item: Item) -> void:
	print("🟡 SEÑAL RECIBIDA: Se quitó el ítem -> ", item.base.id)
	
	if item.base.id == "hacha":
		tiene_hacha = false
		if sprite_hacha:
			sprite_hacha.visible = false
		print("🔴 ¡Arma oculta!")


func _physics_process(_delta):
	if is_attacking:
		move_and_slide() 
		return

	if Input.is_action_just_pressed("attack") and tiene_hacha:
		is_attacking = true
		velocity = Vector2.ZERO 
		
		animation_player.play("attack_" + ultima_direccion)
		
		await animation_player.animation_finished
		
		is_attacking = false 
		return

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


func recoger_item(id_del_item: String) -> void:
	var inventario = InventorySystem.get_player_inventory()
	
	if inventario:
		var guardado_exitoso = inventario.create_item_by_id(id_del_item, 1)
		
		if guardado_exitoso:
			print("¡" + id_del_item + " guardado en el inventario con éxito!")
		else:
			print("El inventario está lleno o el ID del ítem no existe en tu base de datos.")
	else:
		print("Error: No se encontró el inventario del jugador.")


func actualizar_posicion_hacha() -> void:
	if not tiene_hacha or not sprite_hacha:
		return
	
	if ultima_direccion == "SO":
		sprite_hacha.flip_h = true
	else:
		sprite_hacha.flip_h = false
