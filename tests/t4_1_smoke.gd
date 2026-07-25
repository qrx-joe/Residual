extends SceneTree

const Save03CoreVisualScript := preload(
	"res://scripts/visual/save_03_core_visual.gd"
)

var _failures: Array[String] = []


func _initialize() -> void:
	var core: Node3D = Save03CoreVisualScript.new()
	core.model_root = Node3D.new()
	core.indicator_mesh = MeshInstance3D.new()
	core.flow_mesh = MeshInstance3D.new()
	core.protection_halo = MeshInstance3D.new()
	core.crack_overlay = MeshInstance3D.new()
	core.ghost_echo = MeshInstance3D.new()

	core.add_child(core.model_root)
	core.add_child(core.indicator_mesh)
	core.add_child(core.flow_mesh)
	core.add_child(core.protection_halo)
	core.add_child(core.crack_overlay)
	core.add_child(core.ghost_echo)
	root.add_child(core)

	await process_frame
	var model_instance_id: int = core.model_root.get_instance_id()

	_assert_state(
		core,
		Save03CoreVisualScript.VisualState.CALM,
		Save03CoreVisualScript.CALM_COLOR,
		false,
		false,
		false,
		false
	)
	_assert_state(
		core,
		Save03CoreVisualScript.VisualState.OBSERVING,
		Save03CoreVisualScript.OBSERVING_COLOR,
		true,
		false,
		false,
		false
	)
	_assert_state(
		core,
		Save03CoreVisualScript.VisualState.PROTECTING,
		Save03CoreVisualScript.PROTECTING_COLOR,
		false,
		true,
		false,
		false
	)
	_assert_state(
		core,
		Save03CoreVisualScript.VisualState.HOSTILE,
		Save03CoreVisualScript.HOSTILE_COLOR,
		false,
		false,
		true,
		false
	)
	_assert_state(
		core,
		Save03CoreVisualScript.VisualState.GHOST,
		Save03CoreVisualScript.GHOST_COLOR,
		false,
		false,
		false,
		true
	)

	_check(
		core.model_root.get_instance_id() == model_instance_id,
		"state changes must retain the same model instance"
	)

	if _failures.is_empty():
		print("T4.1 smoke: 5 visual states passed without model reload")
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		quit(1)


func _assert_state(
	core: Node3D,
	state: int,
	expected_color: Color,
	flow_visible: bool,
	halo_visible: bool,
	cracks_visible: bool,
	ghost_visible: bool
) -> void:
	core.set_visual_state(state)
	var snapshot: Dictionary = core.get_state_snapshot()
	_check(
		int(snapshot.get("state")) == state,
		"state %d must be active" % state
	)
	_check(
		_colors_match(
			snapshot.get("indicator_color", Color.BLACK),
			expected_color
		),
		"state %d must use the expected indicator color" % state
	)
	_check(
		bool(snapshot.get("flow_visible")) == flow_visible,
		"state %d flow visibility mismatch" % state
	)
	_check(
		bool(snapshot.get("halo_visible")) == halo_visible,
		"state %d halo visibility mismatch" % state
	)
	_check(
		bool(snapshot.get("cracks_visible")) == cracks_visible,
		"state %d crack visibility mismatch" % state
	)
	_check(
		bool(snapshot.get("ghost_visible")) == ghost_visible,
		"state %d ghost visibility mismatch" % state
	)


func _colors_match(left: Color, right: Color) -> bool:
	return (
		is_equal_approx(left.r, right.r)
		and is_equal_approx(left.g, right.g)
		and is_equal_approx(left.b, right.b)
	)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
