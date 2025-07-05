# Esse script controla o comportamento de um "animal" que pode ser arrastado e lançado
# Herda de RigidBody2D para usar física realista (gravidade, colisão, etc.)

extends RigidBody2D

# Enum para definir os estados possíveis do animal
enum AnimalState { Ready, Drag, Release }

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

# Função executada quando o nó entra na cena
func _ready() -> void:
	setup() # Inicializa as configurações do objeto

# Configurações iniciais do objeto
func setup() -> void:
	_arrow_scale_x = arrow.scale.x # Salva a escala original da seta
	arrow.hide()					# Oculta a seta no início
	_start = position				# Salva a posição inicial do animal para referência

# Processamento físico contínuo (a cada frame de física)
func _physics_process(delta: float) -> void:
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

# Evento chamado quando há um clique ou interação com o corpo (ainda não implementado)
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Aqui será implementado o comportamento de arrastar e soltar

# Evento chamado quando o corpo sai da tela (útil para resetar ou remover o objeto)
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Pode ser usado para remover ou reiniciar o objeto

# Evento chamado quando o estado de "dormindo" muda (útil para ativar física ou efeitos)
func _on_sleeping_state_changed() -> void:
	pass # Pode tocar um som ou mudar o estado

# Evento chamado quando o corpo colide com outro (ex: tocar som ou pontuar)
func _on_body_entered(body: Node) -> void:
	pass # Pode reagir à colisão com outros objetos
