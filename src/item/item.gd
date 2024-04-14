@tool
class_name Item extends Sprite2D
	


var moving: bool


@export var board: Board
@export var update_texture: bool = false:
	set(value):
		texture = item_info.texture
@export var item_info: ItemInfo


func _process(delta: float) -> void:
	var map_coords: Vector2i = board.local_to_map(position)
	if map_coords in board.placed_tiles:
		var tile_im_on: Board.Tile = board.placed_tiles[map_coords]
		if not moving and tile_im_on.tile_info.push_items:
			var new_pos: Vector2 = position + Vector2(tile_im_on.push_vec) * Vector2(board.tile_set.tile_size) * board.scale
			moving = true
			var tween = create_tween()
			tween.tween_property(self, "position", new_pos, tile_im_on.tile_info.push_item_time)
			tween.tween_callback(func(): moving = false)
