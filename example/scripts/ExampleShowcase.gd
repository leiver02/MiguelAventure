extends Control

@export var item_id_field: LineEdit
@export var create_item_btn: Button

@export var stash_button: Button
@export var stash_panel: Control

@export var npc1_button: Button
@export var vendor1: VendorComponent
@export var npc2_button: Button
@export var vendor2: VendorComponent
@export var vendor_inventory: VendorInventory

# Hacemos que la salud sea opcional con un 'if' en el _ready
@export var player_health: HealthComponent
@export var health_label: Label

var player: ExamplePlayer

func _ready() -> void:
	# Intentamos buscar al jugador de forma segura
	var players = get_tree().get_nodes_in_group("Player")
	if not players.is_empty():
		player = players[0] as ExamplePlayer

	# Validamos si existe el componente de vida antes de conectarlo
	if player_health and health_label:
		player_health.health_changed.connect(_on_health_changed)
		_on_health_changed(player_health._health, player_health._max_health)
	elif health_label:
		health_label.text = "100 / 100" # Texto por defecto si no usas el componente

	# Conectamos los botones de la UI de forma segura (solo si se asignaron en el Inspector)
	if create_item_btn:
		create_item_btn.pressed.connect(_on_create_item_pressed)
	if stash_button:
		stash_button.pressed.connect(_on_stash_pressed)
	if npc1_button:
		npc1_button.pressed.connect(_on_npc1_pressed)
	if npc2_button:
		npc2_button.pressed.connect(_on_npc2_pressed)

func _on_create_item_pressed() -> void:
	if not item_id_field:
		return
		
	var item_id = item_id_field.text.strip_edges()
	if item_id.is_empty():
		push_warning("Item ID field is empty.")
		return
	
	var base_item = InventorySystem.get_item_base(item_id)
	if not base_item:
		push_warning("No base item found with ID: %s" % item_id)
		return
	
	var player_inv = InventorySystem.get_player_inventory()
	if player_inv:
		player_inv.create_item(base_item, 1)

func _on_health_changed(health: int, max_health: int) -> void:
	if health_label:
		health_label.text = "%d / %d" % [health, max_health]

func _on_stash_pressed() -> void:
	if stash_panel:
		stash_panel.visible = not stash_panel.visible

func _on_npc1_pressed() -> void:
	if not vendor_inventory or not vendor1:
		return
	vendor_inventory.visible = true
	if vendor_inventory.visible:
		vendor_inventory.set_vendor(vendor1)

func _on_npc2_pressed() -> void:
	if not vendor_inventory or not vendor2:
		return
	vendor_inventory.visible = true
	if vendor_inventory.visible:
		vendor_inventory.set_vendor(vendor2)
