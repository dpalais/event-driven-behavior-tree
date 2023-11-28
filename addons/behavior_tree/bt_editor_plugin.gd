@tool
class_name BTEditorPlugin
extends EditorPlugin

enum BTNodeType { COMPOSITE, LEAF, VALUE }
signal bt_node_type_selected(Array)

var _editor : BTEditor = preload ("graph/editor.tscn").instantiate()
var _bottom_panel_button : Button

var _file_dialog : EditorFileDialog
var _type_popup : PopupMenu
var _composite_type_popup : PopupMenu
var _leaf_type_popup : PopupMenu
var _value_type_popup : PopupMenu

var _debugger : BTDebugger
var _editor_interface : EditorInterface

const _composite_submenu_name := "Composite"
const _leaf_submenu_name := "Leaf"
const _value_submenu_name := "Value"



func _enter_tree():
	_debugger = BTDebugger.new()
	_debugger.debug_tree.connect(_on_Debugger_debug_tree)
	_debugger.debug_mode_changed.connect(_on_Debugger_debug_mode_changed)
	add_debugger_plugin(_debugger)

	_bottom_panel_button = add_control_to_bottom_panel(_editor, "Behavior Tree")

	_file_dialog = EditorFileDialog.new()
	_file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_file_dialog.add_filter("*.tres, *.res", "Resources")
	_file_dialog.get_cancel_button().pressed.connect(_on_FileDialog_canceled)

	_type_popup = PopupMenu.new()
	_type_popup.close_requested.connect(_on_TypePopup_close_requested)
	_composite_type_popup = PopupMenu.new()
	_composite_type_popup.name = _composite_submenu_name
	_composite_type_popup.id_pressed.connect(_on_TypePopup_id_pressed.bind(BTNodeType.COMPOSITE))
	_type_popup.add_child(_composite_type_popup)

	_leaf_type_popup = PopupMenu.new()
	_leaf_type_popup.name = _leaf_submenu_name
	_leaf_type_popup.id_pressed.connect(_on_TypePopup_id_pressed.bind(BTNodeType.LEAF))
	_type_popup.add_child(_leaf_type_popup)

	_value_type_popup = PopupMenu.new()
	_value_type_popup.name = _value_submenu_name
	_value_type_popup.id_pressed.connect(_on_TypePopup_id_pressed.bind(BTNodeType.VALUE))
	_type_popup.add_child(_value_type_popup)
	_editor_interface = get_editor_interface()
	var base_control = _editor_interface.get_base_control()
	base_control.add_child(_file_dialog)
	base_control.add_child(_type_popup)

	_editor.plugin = self


func _exit_tree():
	remove_debugger_plugin(_debugger)
	remove_control_from_bottom_panel(_editor)

	_file_dialog.queue_free()
	_type_popup.queue_free()
	_editor.queue_free()



func inspect_object(object : Object, for_property := "", inspector_only := false) -> void:
	_editor_interface.inspect_object(object, for_property, inspector_only)


func request_file_path(load_mode : bool) -> String:
	_file_dialog.visible = true

	var screen_size : Vector2i = get_viewport().get_visible_rect().end

	_file_dialog.size = Vector2i(700, 400)
	_file_dialog.position = (screen_size - _file_dialog.size) / 2

	if load_mode:
		_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
		_file_dialog.title = "Load Behavior Tree"
	else:
		_file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
		_file_dialog.title = "Save Behavior Tree as"

	var path : String = await _file_dialog.file_selected

	return path


func request_bt_node_type(position : Vector2, has_leaves := true) -> BTItem:
	_type_popup.visible = true
	_type_popup.position = position

	_reload_type_popup(has_leaves)

	var selection : Array = await bt_node_type_selected

	if selection == null: return null

	var known_nodes = _get_known_nodes()

	var script: Script
	var index : int = selection[1]
	if selection[0] == BTNodeType.COMPOSITE:
		script = known_nodes.composites[index]
	elif selection[0] == BTNodeType.LEAF:
		script = known_nodes.leaves[index]
	elif selection[0] == BTNodeType.VALUE:
		script = known_nodes.values[index]

	return script.new()



func _get_known_nodes() -> Resource:
	return load("res://addons/behavior_tree/known_nodes.tres")



func _reload_type_popup(has_leaves : bool) -> void:
	_type_popup.clear()
	_composite_type_popup.clear()
	_leaf_type_popup.clear()
	_value_type_popup.clear()

	var known_nodes := _get_known_nodes()
	var composites : Array = known_nodes.composites
	var leaves : Array = known_nodes.leaves
	var values : Array = known_nodes.values

	var idx := 0
	while idx + 1 < len(composites):
		var node_name : String = composites[idx]
		#var node_script : Script = composites[idx + 1]
		_composite_type_popup.add_item(node_name, idx + 1)
		idx += 2
	_type_popup.add_submenu_item(_composite_submenu_name, _composite_submenu_name)

	if has_leaves:
		idx = 0
		while idx + 1 < len(leaves):
			var node_name : String = leaves[idx]
			#var node_script : Script = leaves[idx + 1]
			_leaf_type_popup.add_item(node_name, idx + 1)
			idx += 2
		_type_popup.add_submenu_item(_leaf_submenu_name, _leaf_submenu_name)

	idx = 0
	while idx + 1 < len(values):
		var node_name : String = values[idx]
		#var node_script : Script = values[idx + 1]
		_value_type_popup.add_item(node_name, idx + 1)
		idx += 2
	_type_popup.add_submenu_item(_value_submenu_name, _value_submenu_name)



func _on_FileDialog_canceled() -> void:
	_file_dialog.file_selected.emit("")


func _on_TypePopup_id_pressed(id : int, type : BTNodeType) -> void:
	bt_node_type_selected.emit([type, id])


func _on_TypePopup_close_requested() -> void:
	bt_node_type_selected.emit(null)


func _on_Debugger_debug_tree(data : Array) -> void:
	_editor.debug_tree(data)


func _on_Debugger_debug_mode_changed(value : bool) -> void:
	_editor.debug_mode = value
