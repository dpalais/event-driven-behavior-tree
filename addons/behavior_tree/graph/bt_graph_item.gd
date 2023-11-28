@tool
class_name BTGraphItem
extends GraphNode

const _SLOT_TYPE_BTNODE := 0
const _SLOT_TYPE_BTVALUE := 1

const _SLOT_COLOR_BTNODE := Color.ORANGE_RED
const _SLOT_COLOR_BTVALUE := Color.STEEL_BLUE

var bt_item : BTItem:
	set = _set_bt_item


func _ready() -> void:
	delete_request.connect(_on_delete_request)
	position_offset_changed.connect(_on_position_offset_changed)


func delete_item():
	if bt_item is BTNode:
		bt_item.parent = null

		if bt_item is BTComposite:
			for child in bt_item.children.duplicate():
				child.parent = null

	queue_free()


func _on_delete_request() -> void:
	delete_item()


func _on_position_offset_changed() -> void:
	bt_item.graph_position = position_offset


func _set_bt_item(value : BTItem) -> void:
	if value == null:
		delete_item()
		return

	bt_item = value


