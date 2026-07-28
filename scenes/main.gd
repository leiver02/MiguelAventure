extends Node2D

# Los nombres aquí deben ser EXACTAMENTE iguales a como están en tu escena Main
@onready var miguel = get_tree().current_scene.get_node_or_null("Node2D/CharacterBody2D")
@onready var contenedor_zanahorias = $InterfazUI/ContenedorZanahorias

func _ready() -> void:
	# Verificamos si encontró a Miguel
	if miguel:
		miguel.vida_cambiada.connect(_actualizar_interfaz)
		print("✅ ¡La Interfaz se conectó a Miguel correctamente!")
	else:
		print("❌ ERROR UI: No se encontró al jugador ($character_body_2d)")

func _actualizar_interfaz(nueva_vida: int) -> void:
	print("🥕 Actualizando pantalla... Mostrando ", nueva_vida, " zanahorias.")
	
	if contenedor_zanahorias:
		var zanahorias = contenedor_zanahorias.get_children() # Toma las 3 imágenes
		for i in range(zanahorias.size()):
			if i < nueva_vida:
				zanahorias[i].visible = true
			else:
				zanahorias[i].visible = false
	else:
		print("❌ ERROR UI: No se encontró el ContenedorZanahorias")
