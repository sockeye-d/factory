class_name Board extends TileMap


@export var item_scene: PackedScene


class Tile extends RefCounted:
	var attached_tilemap: TileMap
	var tile_info: TileInfo
	var push_vec: Vector2i
	var position: Vector2i
	var global_position: Vector2:
		set(value):
			position = attached_tilemap.local_to_map(Vector2(position) * attached_tilemap.transform.affine_inverse())
		get:
			return attached_tilemap.map_to_local(position) * attached_tilemap.transform
	
	func _init(_attached_tilemap: TileMap, _tile_info: TileInfo, _push_vec: Vector2i, _position: Vector2i) -> void:
		attached_tilemap = _attached_tilemap
		position = position
		tile_info = _tile_info
		push_vec = _push_vec
		position = _position


enum Rotation {
	RIGHT,
	UP,
	LEFT,
	DOWN,
}

const rotation_vecs: Dictionary = {
	Rotation.RIGHT: Vector2i.RIGHT,
	Rotation.UP: Vector2i.UP,
	Rotation.LEFT: Vector2i.LEFT,
	Rotation.DOWN: Vector2i.DOWN,
}


const neighbors: Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.LEFT,
	Vector2i.DOWN,
]

## Dictionary<Vector2i, Tile>
var placed_tiles: Dictionary
## Dictionary<Vector2i, Timer>
var timers: Dictionary
var selected_tile: TileInfo
var rot: Rotation
var previous_coords: Vector2i
var layers: Dictionary
var item_layers: Array[Node2D]


func _ready() -> void:
	for i in get_layers_count():
		layers[get_layer_name(i).to_snake_case()] = i
	
	await get_tree().create_timer(0.2).timeout
	
	for i in get_layers_count():
		var node = Node2D.new()
		node.name = "ObjectLayer%s" % i
		
		add_child(node)
		node.z_index = i * 2
		item_layers.append(node)


func _process(delta: float) -> void:
	if selected_tile == null:
		return
	
	var coords: Vector2i = local_to_map(get_local_mouse_position())
	var atlas_pos = selected_tile.atlas_pos + Vector2i(0, rot)
	set_cell(layers.preview, previous_coords)
	set_cell(layers.preview, coords, 0, atlas_pos)
	previous_coords = coords


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			
			if selected_tile == null:
				return
			var coords: Vector2i = local_to_map(get_local_mouse_position())
			var atlas_pos = selected_tile.atlas_pos + Vector2i(0, rot)
			remove_tile(coords)
			if not selected_tile.type == "shovel":
				place_tile(coords, rot, selected_tile)
	
	if event is InputEventKey and not selected_tile == null:
		if selected_tile.directional:
			if event.is_action_pressed("rotate_ccw"):
				rot = int(fposmod(rot - 1, 4)) as Rotation
			
			if event.is_action_pressed("rotate_cw"):
				rot = int(fposmod(rot + 1, 4)) as Rotation


func set_selected_tile(tile_info: TileInfo) -> void:
	selected_tile = tile_info
	print(selected_tile.type)
	if not tile_info.directional:
		rot = 0


## Places a tile and adds it to the placed_tiles dictionary for future use
func place_tile(coords: Vector2i, rot: int, tile_info: TileInfo, override: bool = true) -> bool:
	if coords in placed_tiles and not override:
		# Will not overwrite the existing tile
		return false
	
	var atlas_pos = tile_info.atlas_pos + Vector2i(0, rot) if tile_info.directional else Vector2i.ZERO
	set_cell(tile_info.layer, coords, 0, atlas_pos)
	
	var tile = Tile.new(self, tile_info, rotation_vecs[rot], coords)
	placed_tiles[coords] = tile
	
	# Create the timer that will spawn items, but only if the tile can
	if tile_info.spawn_item:
		var spawn_timer: Timer = Timer.new()
		spawn_timer.wait_time = tile_info.spawn_duration
		spawn_timer.timeout.connect(spawn_item.bind(tile))
		spawn_timer.autostart = true
		timers[coords] = spawn_timer
	
		add_child(spawn_timer)
	
	return true


## Removes a tile and also removes it from the placed tile dictionary
func remove_tile(coords: Vector2i):
	set_cell(layers.layer_0, coords)
	set_cell(layers.layer_1, coords)
	timers.erase(coords)
	placed_tiles.erase(coords)


func spawn_item(tile: Tile):
	var item: Item = item_scene.instantiate()
	
	item.board = self
	item.global_position = tile.global_position
	item_layers[tile.tile_info.spawn_item.layer].add_child(item)
