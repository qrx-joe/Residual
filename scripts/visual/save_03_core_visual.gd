class_name Save03CoreVisual
extends Node3D

signal visual_state_changed(state: VisualState)

enum VisualState {
	CALM,
	OBSERVING,
	PROTECTING,
	HOSTILE,
	GHOST,
}

const CALM_COLOR := Color("#BFE8F0")
const OBSERVING_COLOR := Color("#8FD3D8")
const PROTECTING_COLOR := Color("#72F1E8")
const HOSTILE_COLOR := Color("#D95C5C")
const GHOST_COLOR := Color("#B7F3F4")

@export var model_root: Node3D
@export var indicator_mesh: GeometryInstance3D
@export var flow_mesh: GeometryInstance3D
@export var protection_halo: GeometryInstance3D
@export var crack_overlay: Node3D
@export var ghost_echo: Node3D

var visual_state: VisualState = VisualState.CALM
var _elapsed_seconds: float = 0.0
var _indicator_material: StandardMaterial3D
var _flow_material: StandardMaterial3D
var _halo_material: StandardMaterial3D
var _crack_materials: Array[StandardMaterial3D] = []
var _ghost_materials: Array[StandardMaterial3D] = []


func _ready() -> void:
	_prepare_materials()
	set_visual_state(visual_state, true)


func _process(delta: float) -> void:
	_elapsed_seconds += delta
	_apply_animated_parameters()


func set_visual_state(
	state: VisualState,
	force_refresh: bool = false
) -> void:
	if state == visual_state and not force_refresh:
		return

	visual_state = state
	_elapsed_seconds = 0.0
	_apply_static_parameters()
	_apply_animated_parameters()
	visual_state_changed.emit(visual_state)


func get_state_snapshot() -> Dictionary:
	return {
		"state": visual_state,
		"model_instance_id": (
			model_root.get_instance_id() if model_root != null else 0
		),
		"indicator_color": _indicator_material.emission,
		"indicator_energy": _indicator_material.emission_energy_multiplier,
		"flow_visible": flow_mesh.visible,
		"halo_visible": protection_halo.visible,
		"cracks_visible": crack_overlay.visible,
		"ghost_visible": ghost_echo.visible,
	}


func _prepare_materials() -> void:
	_indicator_material = _create_emission_material(indicator_mesh)
	_flow_material = _create_emission_material(flow_mesh)
	_halo_material = _create_translucent_material(protection_halo)
	_prepare_ghost_echo()
	_crack_materials = _create_materials_for_tree(crack_overlay)
	_ghost_materials = _create_materials_for_tree(ghost_echo)


func _create_emission_material(
	target: GeometryInstance3D
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = CALM_COLOR
	material.emission_energy_multiplier = 1.0
	target.material_override = material
	return material


func _create_translucent_material(
	target: GeometryInstance3D
) -> StandardMaterial3D:
	var material := _create_emission_material(target)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 1.0, 1.0, 0.0)
	return material


func _prepare_ghost_echo() -> void:
	if model_root == null or ghost_echo == null:
		return
	var model_copy := model_root.duplicate() as Node3D
	ghost_echo.add_child(model_copy)
	model_copy.position.x = 0.08


func _create_materials_for_tree(
	target: Node
) -> Array[StandardMaterial3D]:
	var materials: Array[StandardMaterial3D] = []
	for geometry: GeometryInstance3D in _find_geometry_instances(target):
		materials.append(_create_translucent_material(geometry))
	return materials


func _find_geometry_instances(target: Node) -> Array[GeometryInstance3D]:
	var geometry_instances: Array[GeometryInstance3D] = []
	if target is GeometryInstance3D:
		geometry_instances.append(target as GeometryInstance3D)
	for child: Node in target.get_children():
		geometry_instances.append_array(_find_geometry_instances(child))
	return geometry_instances


func _apply_static_parameters() -> void:
	flow_mesh.visible = visual_state == VisualState.OBSERVING
	protection_halo.visible = visual_state == VisualState.PROTECTING
	crack_overlay.visible = visual_state == VisualState.HOSTILE
	ghost_echo.visible = visual_state == VisualState.GHOST

	match visual_state:
		VisualState.CALM:
			_set_emission(_indicator_material, CALM_COLOR, 1.2)
		VisualState.OBSERVING:
			_set_emission(_indicator_material, OBSERVING_COLOR, 1.5)
			_set_emission(_flow_material, OBSERVING_COLOR, 1.3)
		VisualState.PROTECTING:
			_set_emission(_indicator_material, PROTECTING_COLOR, 2.2)
			_set_emission(_halo_material, PROTECTING_COLOR, 1.8, 0.22)
		VisualState.HOSTILE:
			_set_emission(_indicator_material, HOSTILE_COLOR, 2.8)
			for material: StandardMaterial3D in _crack_materials:
				_set_emission(material, HOSTILE_COLOR, 3.2, 0.92)
		VisualState.GHOST:
			_set_emission(_indicator_material, GHOST_COLOR, 1.8)
			for material: StandardMaterial3D in _ghost_materials:
				_set_emission(material, GHOST_COLOR, 1.7, 0.25)


func _apply_animated_parameters() -> void:
	match visual_state:
		VisualState.CALM:
			_indicator_material.emission_energy_multiplier = (
				1.2 + sin(_elapsed_seconds * 1.2) * 0.08
			)
		VisualState.OBSERVING:
			_flow_material.emission_energy_multiplier = (
				1.3 + sin(_elapsed_seconds * 2.0) * 0.35
			)
		VisualState.PROTECTING:
			var halo_alpha: float = (
				0.22 + sin(_elapsed_seconds * 1.6) * 0.06
			)
			_set_material_alpha(_halo_material, halo_alpha)
		VisualState.HOSTILE:
			var hostile_pulse: float = (
				2.8 + absf(sin(_elapsed_seconds * 7.0)) * 2.0
			)
			_indicator_material.emission_energy_multiplier = hostile_pulse
		VisualState.GHOST:
			var ghost_alpha: float = (
				0.18 + absf(sin(_elapsed_seconds * 2.4)) * 0.14
			)
			for material: StandardMaterial3D in _ghost_materials:
				_set_material_alpha(material, ghost_alpha)


func _set_emission(
	material: StandardMaterial3D,
	color: Color,
	energy: float,
	alpha: float = 1.0
) -> void:
	material.emission = color
	material.emission_energy_multiplier = energy
	material.albedo_color = Color(color, alpha)


func _set_material_alpha(
	material: StandardMaterial3D,
	alpha: float
) -> void:
	var color := material.albedo_color
	color.a = alpha
	material.albedo_color = color
