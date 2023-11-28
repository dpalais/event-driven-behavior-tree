@tool
class_name BTGraphNode
extends BTGraphItem



@export var node_slot: Node



const Header := preload("header.tscn")

const _MAIN_COLOR := Color.DARK_GRAY
const _UTILITY_COLOR := Color.DODGER_BLUE
const _CONDITION_COLOR := Color.DARK_ORANGE
const _MODIFIER_COLOR := Color.DARK_OLIVE_GREEN

var _main_slot_position: int
var _slots: Array[Node]

@export var conditions_list : Node
@export var utilities_list : Node
@export var modifiers_list : Node

func _ready() -> void:
	super._ready()
	var _main_slot_position := node_slot.get_index()
	set_slot_color_left(_main_slot_position, _SLOT_COLOR_BTNODE)
	set_slot_color_right(_main_slot_position, _SLOT_COLOR_BTNODE)
	set_slot_type_left(_main_slot_position, _SLOT_TYPE_BTNODE)
	set_slot_type_right(_main_slot_position, _SLOT_TYPE_BTNODE)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	#if event.button_index == MOUSE_BUTTON_LEFT and event.double_click and bt_item is BTSubtree:
		#get_parent().open_tree(BTGraphEdit.OpenTreeMode.SUBTREE, [bt_node.subtree.resource_path, bt_node.tree_index])



func has_point(point : Vector2) -> bool:
	return Rect2(position_offset, size).has_point(point)



func _refresh_visuals() -> void:
	title = bt_item.name
	$BTNode.text = "%s - %s" % [bt_item.sibling_index, bt_item.get_bt_type_name()]

	_refresh_decorator_container($Utilities, bt_item.utilities, _UTILITY_COLOR)
	_refresh_decorator_container($Conditions, bt_item.conditions, _CONDITION_COLOR)
	_refresh_decorator_container($Modifiers, bt_item.modifiers, _MODIFIER_COLOR)


func _refresh_decorator_container(container : Node, elements : Array, color : Color) -> void:
	var i := 0
	var current_list = container.get_children()
	while i < len(current_list):
		var header := current_list[i] as BTGraphHeader

		if i >= len(elements):
			header.queue_free()
		else:
			var decorator = elements[i]
			header.update(decorator.name, color)
		i += 1

	while i < len(elements):
		if elements[i] == null: break

		var header := Header.instantiate()
		container.add_child(header)
		var decorator = elements[i]
		header.update(decorator.name, color)
		i += 1



func _add_value_slots(from : Array) -> void:
	var last : Node = node_slot
	var index : int = 1

	while len(from) > 0:
		var slot : Node = from.pop_front()
		last.add_sibling(slot)
		last = slot

		set_slot_enabled_left(index, true)
		set_slot_color_left(index, _SLOT_COLOR_BTVALUE)
		set_slot_type_left(index, _SLOT_TYPE_BTVALUE)

		index += 1
		_slots.append(slot)



func _remove_value_slots() -> void:
	while len(_slots) > 0:
		var slot : Node = _slots.pop_back()
		set_slot_enabled_left(slot.get_index(), false)
		remove_child(slot)



func _set_bt_item(value : BTItem) -> void:
	var current : BTNode = bt_item
	super._set_bt_item(value)

	if current != null:
		current.changed.disconnect(_refresh_visuals)

		value.parent = current.parent
		current.parent = null
		value.conditions = current.conditions
		value.modifiers = current.modifiers

		if (value is BTComposite and current is BTComposite):
			for child in current.children.duplicate():
				child.parent = value

	set_slot_enabled_right(_main_slot_position, bt_item is BTComposite)

	if (bt_item is BTComposite):
		bt_item.reorder_children()

	bt_item.changed.connect(_refresh_visuals, CONNECT_DEFERRED)
	_refresh_visuals()
