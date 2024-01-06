@tool
## An extention class for [Camera2D] that assists with smooth camera follower, camera shake, and camera zoom.
## @experimental
class_name CameraFollow2D extends Camera2D

## Singals a sucessfully concluded camera shake.[br][br]
##
## See [method shake_event].
signal finish_shake;
## Singals a sucessfully concluded camera zoom.[br][br]
##
## See [method zoom_event].
signal finish_zoom;

@export_group("Follow")

## The [Node2D] this camera will attempt to follow at check update.[br][br]
## 
## [b]NOTE[/b]: If this is not set, the camera will rely on given [Vector2]
## coordinates instead.
@export var follow : Node2D:
	set(val):
		follow = val;
		if val != null:
			update_position(0);
## If [member snap] is [code]true[/code], the camera will snap to [member follow] into range
## whenever [member follow] leaves the max assigned range.
@export var snap          : bool = true;
## If [member follow] is [code]true[/code], the camera will attempt to follow
## [member follow] at each physic_frame independently.[br][br]
##
## [b]WARNING[/b]: This could cause desync. If your [member follow] is moving, it is recomended
## this remain set as [code]false[/code] and you call [method update_position] in the same
## frame [member follow] is moved.  
@export var auto_follow : bool = false:
	set(val):
		set_physics_process(val);
		auto_follow = val;

@export_group("Ranges")

## If [member snap] is [code]true[/code], this is the max distance, in each straight axis,
## in which the camera can be from [member follow] before forcibly snapping into range
## again.
@export var max_range : Vector2 = Vector2(100, 100);
## If the camera's straight axis distance to [member follow] is greater than
## [member desired_range], then the camera will lerp towards these desired
## distances, using [member axis_lerp] as the lerp coefficients for each axis.
@export var desired_range : Vector2 = Vector2(20, 0);
## The lerp coefficients for the camera's smooth transition into
## [member desired_range].
@export var axis_lerp : Vector2 = Vector2(0.15, 0.15):
	set(val):
		axis_lerp = val.clamp(Vector2.ZERO, Vector2(1., 1.));

@export_group("Default")

## The default offset the camera will enact on for shakes.
@export var default_offset   : Vector2 = Vector2(0, 0):
	set(val):
		default_offset = val;
		if _shake_tween && !_shake_tween.is_running():
			offset = val;
var _default_rotation        : float = 0;
## The default rotation, in radians, the camera will enact on.
@export var default_rotation : float = 0:
	get:
		return _default_rotation;
	set(val):
		_default_rotation = val;
		if _shake_tween && !_shake_tween.is_running():
			rotation = val;
			_default_rotation_degrees = rotation_degrees;
		else:
			_default_rotation_degrees = rad_to_deg(val);

var _default_rotation_degrees        : float = 0;
## The default rotation, in degrees, the camera will enact on.
@export var default_rotation_degrees : float = 0:
	get:
		return _default_rotation_degrees;
	set(val):
		_default_rotation_degrees = val;
		if _shake_tween && !_shake_tween.is_running():
			rotation_degrees = val;
			_default_rotation = deg_to_rad(val);
## If [member shake_rotation] is [code]true[/code], the camera's shake
## axes will be impacted by [member default_rotation] and
## [member default_rotation_degrees].
@export var shake_rotation_impacted : bool = true;

# Camera shake
var _shake_tween  : Tween;
var _shaker       : RepeatCaller;
var _rng          : RandomNumberGenerator = RandomNumberGenerator.new();
var _strength     : Vector3 = Vector3.ZERO;

# Camera zoom
var _zoom_tweem : Tween;

func _ready() -> void:
	if !auto_follow:
		set_physics_process(false);
	
	_shaker = RepeatCaller.new();
	add_child(_shaker);
	_shaker.call_func = _shake_func;
	_shaker.stop();
	_shaker.timeout.connect(_reset_values);

func _physics_process(delta: float) -> void:
	if follow:
		update_position(delta);

## Updates the position of the camera, including snapping and easing,
## towards the assigned [member follow].[br]
## This is automatically called every physic_frame when [member auto_follow]
## is [code]true[/code] and [member follow] is not [code]null[/code].[br][br]
##
## [b]NOTE[/b]: If [param delta] is [code]0[/code] or less, this method will
## not ease towards [member follow] any this call.[br][br]
##
## This is a wrapper function for [method update_position_pos].
func update_position(delta : float) -> void:
	if !follow:
		return;
	update_position_pos(delta, follow.position);

## Updates the position of the camera, including snapping and easing
## towards the position given.[br]
##
## [b]NOTE[/b]: If [param delta] is [code]0[/code] or less, this method will
## not ease towards [member follow] any this call.[br][br]
func update_position_pos(delta : float, pos : Vector2) -> void:
	var diff_x = position.x - pos.x;
	var diff_y = position.y - pos.y;
	
	# Snap
	if snap:
		if abs(diff_x) > max_range.x:
			position.x = pos.x + max_range.x * sign(diff_x);
		if abs(diff_y) > max_range.y:
			position.y = pos.y + max_range.y * sign(diff_y);
	
	# Smooth Ease
	if delta > 0:
		if abs(diff_x) > desired_range.x:
			var des_pos_x = pos.x + desired_range.x * sign(diff_x);
			position.x = lerp(position.x, des_pos_x, (axis_lerp.x ** (delta * 100)));
		if abs(diff_y) > desired_range.y:
			var des_pos_y = pos.y + desired_range.y * sign(diff_y);
			position.y = lerp(position.y, des_pos_y, (axis_lerp.y ** (delta * 100)));

## Starts camera shake.[br]
## The shake will have [param stength] shake strength, and will
## lerp to [code]0[/code], with the ratios given in [param decay_spd],
## after [param times] seconds for each exis. Each shake will be
## delayed by [param delay] seconds.[br][br]
##
## [b]NOTE[/b]: For all [Vector3] parameters, [code]x[/code] refers to
## the x-axis, [code]y[/code] refers to the y-axis, and [code]z[/code]
## refers to the angle.[br][br]
##
## [b]NOTE[/b]: Rotation does not work when [member Camera2D.ignore_rotation]
## is set to [code]true[/code].
func shake_event(
				times     : Vector3 = Vector3(0.1, 0.1, 0),
				strength  : Vector3 = Vector3(5., 5., 0),
				decay_spd : Vector3 = Vector3.ZERO,
				delay     : float   = 0.0
				) -> void:
	if _shake_tween:
		_shake_tween.kill();
	_shake_tween = create_tween().set_parallel();
	
	_strength = strength;
	
	if times.x > 0:
		_shake_tween.tween_property(self, "_strength:x", 0.0, decay_spd.x).set_delay(times.x);
	if times.y > 0:
		_shake_tween.tween_property(self, "_strength:y", 0.0, decay_spd.y).set_delay(times.y);
	if times.z > 0:
		_shake_tween.tween_property(self, "_strength:z", 0.0, decay_spd.z).set_delay(times.z);
	_shake_tween.tween_callback(func(): finish_shake.emit());
	
	_shaker.interval = max(times.z + decay_spd.z, times.y + decay_spd.y, times.x + decay_spd.x);
	_shaker.delay = delay;
	_shaker.start();

## Returns if the camera is still shaking.
func is_shaking() -> bool:
	return _shake_tween.is_running();

func _adjusted_strength() -> Vector3:
	
	return Vector3.ZERO;

func _shake_func() -> void:
	offset = default_offset + Vector2(
				_rng.randf_range(-_strength.x, _strength.x),
				_rng.randf_range(-_strength.y, _strength.y)
				);
	if shake_rotation_impacted:
		offset = offset.rotated(_default_rotation);
	
	rotation_degrees = _rng.randf_range(-_strength.z, _strength.z) + _default_rotation_degrees;

func _reset_values() -> void:
	offset           = default_offset;
	rotation_degrees = _default_rotation_degrees;

## Starts camera zoom.[br]
## The zoom will take [param times], for each axis, to zoom
## towards the desired range [param zoom_target].
func zoom_event(
				times       : Vector2,
				zoom_target : Vector2,
				trans       : Tween.TransitionType = Tween.TRANS_SINE,
				ease_       : Tween.EaseType       = Tween.EASE_IN_OUT
				) -> void:
	if _zoom_tweem:
		_zoom_tweem.kill();
	
	_zoom_tweem = create_tween().set_parallel();
	_zoom_tweem.set_ease(ease_);
	_zoom_tweem.set_trans(trans);
	if times.x > 0:
		_zoom_tweem.tween_property(self, "zoom:x", zoom_target.x, times.x);
	if times.y > 0:
		_zoom_tweem.tween_property(self, "zoom:y", zoom_target.y, times.y);
	_zoom_tweem.tween_callback(func(): finish_zoom.emit());

## Returns if the camera is still zooming.
func is_zooming() -> bool:
	return _zoom_tweem.is_running();
