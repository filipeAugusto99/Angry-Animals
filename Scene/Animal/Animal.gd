#region

# Esse script controla o comportamento de um "animal" que pode ser arrastado e lançado
# Herda de RigidBody2D para usar física realista (gravidade, colisão, etc.)

extends RigidBody2D
# Enum para definir os estados possíveis do animal
enum AnimalState { Ready, Drag, Release }

const DRAG_LIM_MAX: Vector2 = Vector2(0, 60)
const DRAG_LIM_MIN: Vector2 = Vector2(-60, 0)
const IMPULSE_MULT: float = 20.0
const IMPULSE_MAX: float = 1200.0

# Referências para nós filhos, inicializadas quando o nó está pronto
@onready var arrow: Sprite2D = $Arrow  # Seta visual de direção e força
@onready var debug_label: Label = $DebugLabel # Label para mostrar informações de depuração
@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound # Som de lançamento
@onready var kick_sound: AudioStreamPlayer2D = $KickSound # Som de impacto ou chute
@onready var stretch_sound: AudioStreamPlayer2D = $StretchSound # Som de esticada ao arrastar


# Variáveis internas para controle de estado e movimento
var _state: AnimalState = AnimalState.Ready # Estado atual do animal
var _start: Vector2 = Vector2.ZERO # Posição inicial do corpo (ponto de origem)
var _drag_start: Vector2 = Vector2.ZERO  # Posição onde o clique (ou toque) começou
var _dragged_vector: Vector2 = Vector2.ZERO # Vetor que representa o quanto o objeto foi arrastado
var _arrow_scale_x: float = 0.0 # Escala original da seta na horizontal (usado para restaurar ou ajustar)

# Trata entradas que não foram capturadas diretamente por um nó com foco.
# Aqui detecta quando o jogador solta o botão de arrasto e muda o estado para "Release".
func _unhandled_input(event: InputEvent) -> void:
	if _state == AnimalState.Drag and event.is_action_released("drag"):
		change_state(AnimalState.Release)
		call_deferred("change_state", AnimalState.Release)  # Garante que a transição ocorra fora do ciclo atual de entrada

# Função executada quando o nó entra na cena
func _ready() -> void:
	setup() # Inicializa as configurações do objeto

# Configurações iniciais do objeto
func setup() -> void:
	_arrow_scale_x = arrow.scale.x # Salva a escala original da seta
	arrow.hide()					# Oculta a seta no início
	_start = position				# Salva a posição inicial do animal para referência

# Processamento físico contínuo (a cada frame de física)
func _physics_process(_delta: float) -> void:
	update_state()
	update_debug_label() # Atualiza o texto de depuração

# Atualiza o label de debug com informações úteis do estado atual
func update_debug_label() -> void:
	var ds: String = "ST:%s SL:%s FR:%s\n" % [
		AnimalState.keys()[_state], # Estado atual como string
		sleeping,					# Se o corpo está "dormindo" (parado)
		freeze						# Se o corpo está congelado (sem movimentação)
	]
	
	# Mostra posições de arrasto formatadas com 1 casa decimal
	ds += "_drag_start:%.1f, %.1f\n" % [_drag_start.x, _drag_start.y]
	ds += "_dragged_vector:%.1f, %.1f" % [_dragged_vector.x, _dragged_vector.y]
	debug_label.text = ds # Atualiza o texto na tela

#endregion

#region drag

func update_arrow_scale() -> void:
	var imp_len: float = calculate_impulse().length()
	var perc: float = clamp(imp_len / IMPULSE_MAX, 0.0, 1.0)
	arrow.scale.x = lerp(_arrow_scale_x, _arrow_scale_x * 2, perc )
	arrow.rotation = (_start - position).angle()

# Inicia o processo de arrasto do objeto:
func start_dragging() -> void:
	arrow.show()    # - Mostra a seta visual (usada para indicar direção/força)
	_drag_start = get_global_mouse_position() # - Salva a posição inicial do clique/touch do mouse para calcular a força depois

# Calcula e aplica o comportamento visual e físico do arrasto
func handle_dragging() -> void:
	# Calcula o vetor entre a posição atual do mouse e a posição onde o arrasto começou
	var new_drag_vector: Vector2 = get_global_mouse_position() - _drag_start
	
	# Limita o vetor de arrasto dentro de um intervalo mínimo e máximo (impede arrasto exagerado)
	new_drag_vector = new_drag_vector.clamp(
		DRAG_LIM_MIN, DRAG_LIM_MAX
	)
	
	# Calcula a diferença entre o vetor anterior e o novo
	var diff: Vector2 = new_drag_vector - _dragged_vector
	
	# Se houve movimento e o som de esticada ainda não está tocando, toca o som
	if diff.length() > 0 and stretch_sound.playing == false:
		stretch_sound.play()
	
	# Atualiza o vetor de arrasto armazenado
	_dragged_vector = new_drag_vector	
	
	# Atualiza a posição do objeto na cena com base na posição inicial + vetor de arrasto
	position = _start + _dragged_vector
	
	update_arrow_scale()
	
#endregion

#region release
# Região responsável por iniciar o comportamento de "soltura" (release),
# ou seja, o momento em que o objeto é lançado após o arrasto.

# Define uma função que calcula o vetor de impulso (força de lançamento)
func calculate_impulse() -> Vector2:
	# Retorna o vetor de arrasto multiplicado por um fator de impulso (e invertido)
	# - _dragged_vector: representa o quanto o objeto foi puxado (arrastado)
	# - IMPULSE_MULT: é um multiplicador que ajusta a força final do lançamento
	# - O sinal negativo inverte o vetor, pois o lançamento é na direção oposta ao arrasto
	return _dragged_vector * -IMPULSE_MULT
	
func start_release() -> void:
	arrow.show()  # Garante que a seta ainda esteja visível (pode ser ocultada depois se preferir)
	launch_sound.play() # Toca o som de lançamento
	freeze = false # Descongela o corpo para que ele reaja à física (gravidade, colisão, etc.)
	apply_central_impulse(calculate_impulse()) #aplica uma força instantânea (um impulso) ao corpo físico (RigidBody2D) NO CENTRO do objeto, simulando um lançamento ou "empurrão".
	
#endregion

#region state
# Região que lida com a lógica de atualização de estado e executa ações específicas para cada estado.

# Atualiza o comportamento do objeto com base em seu estado atua
func update_state() -> void:
	match _state:
		AnimalState.Drag:
			handle_dragging()  # Se estiver sendo arrastado, atualiza a posição em tempo real

# Muda o estado atual do objeto de forma segura:
func change_state(new_state: AnimalState) -> void:
	if _state == new_state: # - Evita mudar se já estiver no mesmo estado
		return # Evita repetição de lógica se já estiver no estado desejado
	
	_state = new_state  # Atualiza o estado interno
	
	match _state:
		# Quando entra no estado Drag (arrasto), inicia o comportamento de arrastar
		AnimalState.Drag:
			start_dragging() # Inicia o arrasto
		AnimalState.Release:
			start_release() # Executa a lógica de soltura (lançamento)
#endregion


#region signals
# Evento chamado quando há um clique ou interação com o corpo (ainda não implementado)
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# - Se a ação configurada como "drag" for pressionada e o estado for Ready
	if event.is_action_pressed("drag") and _state == AnimalState.Ready:
		#   (ou seja, o objeto está pronto para ser arrastado), muda o estado para Drag
		change_state(AnimalState.Drag)

# Evento chamado quando o corpo sai da tela (útil para resetar ou remover o objeto)
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Pode ser usado para remover ou reiniciar o objeto

# Evento chamado quando o estado de "dormindo" muda (útil para ativar física ou efeitos)
func _on_sleeping_state_changed() -> void:
	pass # Pode tocar um som ou mudar o estado

# Evento chamado quando o corpo colide com outro (ex: tocar som ou pontuar)
func _on_body_entered(body: Node) -> void:
	pass # Pode reagir à colisão com outros objetos

#endregion
