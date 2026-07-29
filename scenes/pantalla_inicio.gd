extends CanvasLayer

# Ruta hacia la escena principal del juego (según tu panel de archivos se llama Main.tscn)
const ESCENA_JUEGO = "res://scenes/Main.tscn"


func _on_button_pressed() -> void:
	# Aseguramos que el juego no empiece pausado
	get_tree().paused = false
	
	# Cambiamos a la escena principal de Miguel
	get_tree().change_scene_to_file(ESCENA_JUEGO)


func _on_button_2_pressed() -> void:
	# Cierra el juego por completo
	get_tree().quit()
