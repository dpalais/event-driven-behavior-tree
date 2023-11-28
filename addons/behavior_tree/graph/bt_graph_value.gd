@tool
class_name BTGraphValue
extends BTGraphItem

func _ready() -> void:
	super._ready()
	set_slot_color_right(0, _SLOT_COLOR_BTVALUE)
	set_slot_type_right(0, _SLOT_TYPE_BTVALUE)


func _refresh_visuals() -> void:
	title = bt_item.name

