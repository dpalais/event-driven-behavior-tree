@tool
class_name BTKnownNodes
extends Resource

@export var composites: Array
@export var conditions: Array
@export var leaves: Array
@export var utilities: Array
@export var values: Array

@export var additional_nodes: BTKnownNodes

func get_composite_nodes() -> Array:
	var additional = [] if additional_nodes == null else additional_nodes.composites
	return _get_nodes(composites, additional)

func get_condition_nodes() -> Array:
	var additional = [] if additional_nodes == null else additional_nodes.conditions
	return _get_nodes(composites, additional)

func get_leaf_nodes() -> Array:
	var additional = [] if additional_nodes == null else additional_nodes.leaves
	return _get_nodes(leaves, additional)

func get_utility_nodes() -> Array:
	var additional = [] if additional_nodes == null else additional_nodes.utilities
	return _get_nodes(utilities, additional)

func get_value_nodes() -> Array:
	var additional = [] if additional_nodes == null else additional_nodes.values
	return _get_nodes(values, additional)

func _get_nodes(from: Array, additional: Array = []) -> Array:
	var ret := from.duplicate()
	ret.append_array(additional)
	return ret
