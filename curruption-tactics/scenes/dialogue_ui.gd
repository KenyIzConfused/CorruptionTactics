extends CanvasLayer

@onready var panel = get_node_or_null("Panel")
@onready var text_label = get_node_or_null("Panel/DialogueText")
@onready var next_button = get_node_or_null("Panel/NextButton")
@onready var next_stage_btn = get_node_or_null("Panel/NextStageButton")

# Stage 1 Lines (Pigs)
var stage_1_lines: Array[String] = [
	"Hey! Come join us defeat the corruption.",
	"Pigs and crocs are all over, they must be brought down!",
	"The pigs are coming!",
	"Prepare to fight!"
]

# Stage 2 Lines (Crocs)
var stage_2_lines: Array[String] = [
	"Hello again, you did well back there.",
	"pigs am right!",
	"we are getting closer to our final destination!",
	"I gotta go, don't get bitten!"
]

var current_lines: Array[String] = []
var index: int = 0
var player_ref = null
var npc_ref = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	hide()
	if next_stage_btn: next_stage_btn.hide()

func start_dialogue(player, npc, npc_inspector_lines: Array[String]):
	player_ref = player
	npc_ref = npc
	index = 0
	
	# Checks the file path to see if we are in battleground2
	var path = get_tree().current_scene.scene_file_path.to_lower()
	
	if npc_inspector_lines.size() > 0:
		current_lines = npc_inspector_lines
	elif "battleground2" in path:
		current_lines = stage_2_lines
	else:
		current_lines = stage_1_lines
	
	if text_label and current_lines.size() > 0:
		text_label.text = current_lines[index]
	
	show()
	if panel: panel.show()
	if next_button: next_button.show()
	if next_stage_btn: next_stage_btn.hide()
	get_tree().paused = true

func _on_next_button_pressed():
	index += 1
	if index < current_lines.size():
		if text_label: text_label.text = current_lines[index]
	else:
		hide()
		get_tree().paused = false
		if player_ref: player_ref.is_talking = false
		if npc_ref and npc_ref.has_method("walk_away"): npc_ref.walk_away()
		
		var spawner = get_tree().root.find_child("Spawner", true, false)
		if spawner: spawner.start_spawning()

func show_next_stage_button():
	show()
	if panel: panel.show()
	if next_button: next_button.hide() 
	if next_stage_btn: next_stage_btn.show()
	
	var path = get_tree().current_scene.scene_file_path.to_lower()
	if "battleground2" in path:
		text_label.text = "Victory! Proceed to the Final Level?"
	else:
		text_label.text = "Area Clear! Go to Battleground 2?"

func _on_next_stage_button_pressed():
	get_tree().paused = false 
	var path = get_tree().current_scene.scene_file_path.to_lower()
	if "battleground2" in path:
		get_tree().change_scene_to_file("res://scenes/final_level.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/battleground2.tscn")
