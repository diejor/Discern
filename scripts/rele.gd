@tool
extends SubViewport
@onready var cam = $"../Camera2D"
var project_viewport: Vector2i;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	project_viewport = Vector2i(width, height);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	global_canvas_transform = Transform2D(0, Vector2(width/2., height/2.))
	if not Engine.is_editor_hint():
		size = cam.get_viewport_rect().size
		global_canvas_transform = cam.get_viewport_transform()
	else:

		size = Vector2i(width, height)
	
