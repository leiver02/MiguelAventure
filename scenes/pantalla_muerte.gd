extends CanvasLayer

func _on_boton_reintentar_pressed() -> void:
	# 1. Despausamos el juego
	get_tree().paused = false
	
	# 2. Eliminamos esta pantalla de muerte de la memoria
	queue_free()
	
	# 3. Recargamos el nivel actual
	get_tree().reload_current_scene()


func _on_boton_menu_pressed() -> void:
	# 1. Despausamos el juego
	get_tree().paused = false
	
	# 2. Eliminamos esta pantalla de muerte de la memoria
	queue_free()
	
	# 3. Cambiamos a la pantalla de inicio
	get_tree().change_scene_to_file("res://scenes/PantallaInico.tscn")
