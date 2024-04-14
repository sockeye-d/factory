@tool
class_name TileSelector extends ScrollContainer


signal tile_selected(tile_info: TileInfo)


@export var update_tiles: bool:
	set(value):
		if value:
			_update_tiles()

@export_dir var tile_info_dir:
	set(value):
		tile_info_dir = value
		_update_tiles()
	get:
		return tile_info_dir

@export var tile_infos: Array[TileInfo]:
	set(value):
		tile_infos = value
		
		tile_info_dict = {}
		for child in $TileButtonContainer.get_children():
			child.queue_free()
		for tile_info in tile_infos:
			var child = ModulateTextureButton.new()
			child.texture = tile_info.icon
			child.pressed.connect(set_selected_tile_info.bind(child))
			$TileButtonContainer.add_child(child)
			#$TileButtonContainer.move_child(child, 0)
			tile_info_dict[child] = tile_info
	get:
		return tile_infos
var scroll_target: float = 0.0
var tile_info_dict: Dictionary = {}


func _process(delta: float) -> void:
	scroll_horizontal = _damp(scroll_horizontal, scroll_target, 0.5, delta)


func scroll(amount: float) -> void:
	scroll_target = clampf(
			scroll_target + amount,
			get_h_scroll_bar().min_value,
			get_h_scroll_bar().max_value,
			)


func set_selected_tile_info(btn: ModulateTextureButton) -> void:
	var info: TileInfo = tile_info_dict[btn]
	#print(info.type)
	tile_selected.emit(info)


func _damp(current_value: float, target_value: float, smoothing: float, dt: float) -> float:
	return lerpf(target_value, current_value, pow(smoothing, dt))


func _update_tiles() -> void:
	var infos: Array[TileInfo] = []
	for tile_info in DirAccess.get_files_at(tile_info_dir):
		if not tile_info.get_extension() == "tres":
			continue
		
		var info = load(tile_info_dir + "/" + tile_info)
		
		if not info is TileInfo:
			continue
		
		infos.append(info)
	
	if infos.size() > 0:
		tile_infos = infos
