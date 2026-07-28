extends StaticBody2D

var vida_arbol: int = 3 

func _ready() -> void:
	print("🌳 Árbol listo en la escena.")

func recibir_hachazo() -> void:
	vida_arbol -= 1
	print("🌳 ¡Árbol golpeado! Golpes restantes: ", vida_arbol)
	
	if vida_arbol <= 0:
		print("🪵 ¡El árbol cayó!")
		queue_free()
