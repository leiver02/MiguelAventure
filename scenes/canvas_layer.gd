extends CanvasLayer

# Ajusta esto para acelerar o ralentizar el día
const VELOCIDAD_TIEMPO = 60.0 # Cada 1 segundo real, pasarán 10 minutos en el juego

# Variables iniciales del tiempo
var dia: int = 1
var hora: int = 0       # El juego iniciará a las 6:00 AM (Amanecer)
var minuto: int = 0
var tiempo_acumulado: float = 0.0

# Enlaces directos a tus componentes de la escena
@onready var disco_ciclo = $InterfazReloj/DiscoCiclo
@onready var aguja = $InterfazReloj/Aguja
@onready var texto_dia = $InterfazReloj/TextoDia
@onready var texto_hora = $InterfazReloj/TextoHora

func _process(delta: float):
	# 1. Ejecutar el reloj interno paso a paso
	tiempo_acumulado += delta * VELOCIDAD_TIEMPO
	if tiempo_acumulado >= 1.0:
		minuto += 1
		tiempo_acumulado = 0.0
		
		if minuto >= 60:
			minuto = 0
			hora += 1
			
			if hora >= 24:
				hora = 0
				dia += 1

	# 2. Actualizar las etiquetas de texto en pantalla
	texto_dia.text = "Day: " + str(dia)
	texto_hora.text = "%02d:%02d" % [hora, minuto]

	# 3. Rotar la aguja según la hora decimal actual
	var hora_decimal = hora + (minuto / 60.0)
	# Convertimos la hora a radianes (TAU es un círculo completo)
	
	aguja.rotation = (hora_decimal / 11.2) * TAU
	
# 4. Sincronizar el fondo de manera fluida
	var fraccion_del_dia : float = hora_decimal / 24.0
	var frame_flotante : float = fraccion_del_dia * disco_ciclo.hframes
	
	# Calculamos el número entero lógico (del 0 al total de hframes - 1)
	var frame_logico = int(fmod(floor(frame_flotante), disco_ciclo.hframes))

	# Asignamos el frame real usando una función de mapeo
	disco_ciclo.frame = obtener_frame_mapeado(frame_logico)

	# Nueva función para controlar excepciones de frames
func obtener_frame_mapeado(frame_original: int) -> int:
	if frame_original == 16:
		return  17
	if frame_original == 17:
		return  18  
	
	return frame_original
