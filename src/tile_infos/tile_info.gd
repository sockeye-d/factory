@tool
class_name TileInfo extends Resource


@export var type: StringName = resource_path:
	set(value):
		if value:
			type = value
		else:
			type = resource_path.get_file().split(".")[0]
	get:
		return type
@export var icon: Texture2D
@export var atlas_pos: Vector2i
@export var layer: int
@export var directional: bool

@export_category("Item interactions")
@export var spawn_item: ItemInfo = null
@export var push_items: bool = false
@export var push_item_time: float
@export var spawn_in_front: bool = false
@export_range(0.01, 10.0, 0.0001, "or_greater", "or_less") var spawn_duration: float = 0.0
