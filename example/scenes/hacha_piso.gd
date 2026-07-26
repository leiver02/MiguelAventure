extends Area2D

var jugador_cerca: CharacterBody2D = null

# OJO: Cambia "hacha" por el ID exacto que le pusiste a tu ItemBase del hacha en tu sistema
@export var item_id: String = "hacha"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	# Ahora buscamos una función general llamada recoger_item
	if body.has_method("recoger_item"): 
		jugador_cerca = body

func _on_body_exited(body: Node2D) -> void:
	if body == jugador_cerca:
		jugador_cerca = null

func _unhandled_input(event: InputEvent) -> void:
	if jugador_cerca and event.is_action_pressed("ui_accept"):
		# Le enviamos el ID del ítem a Miguel
		jugador_cerca.recoger_item(item_id)
		queue_free()
