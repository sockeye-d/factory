@tool
class_name ItemInfo extends Resource


enum MovementFlags {
	NONE = 0,
	CONVEYOR_BELT = 1,
	SOMETHING_ELSE = 2,
}


@export var type: StringName = resource_path:
	set(value):
		if value:
			type = value
		else:
			type = resource_path.get_file().split(".")[0]
	get:
		return type
@export var texture: Texture2D
@export var layer: int
