@tool
extends TileMapLayer
@onready var cam = $"../Camera2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	material.set_shader_parameter("project_viewport", Vector2(width, height))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
