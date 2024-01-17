@tool
class_name AnimatedTextureRect extends TextureRect

signal is_playing

@export var sprites: SpriteFrames:
	set(value):
		sprites = value
		if sprites == null:
			animation = '';
			texture = null;
		notify_property_list_changed();
@export var autoplay: bool = false;

var animation: String;
var frame: int;
var speed_scale: float;

var paused: bool = false;

var _refresh_rate: float = 1.0;
var _fps: float = 30.0;
var _playing : bool = false;
var playing: bool = false:
	get:
		return _playing
	set(val):
		if val:
			play();
		else:
			stop();

func _get_property_list():
	var properties = [];

	if sprites != null:
		properties.append({
			"name": "playing",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_EDITOR
		});
		
		properties.append({
			"name": "Animation",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(sprites.get_animation_names())
		});
		
		var frames = [];
		if !animation.is_empty():
			for i in sprites.get_frame_count(animation):
				frames.append(i)
		properties.append({
			"name": "Frame",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": ",".join([str(frames.min()), str(frames.max())])
		});

		properties.append({
			"name": "Speed Scale",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT
		});

	return properties;

func _get(property: StringName):
	if property == &"Animation":
		return animation;
	if property == &"Frame":
		return frame;
	if property == &"Speed Scale":
		return speed_scale;

func _set(property: StringName, value) -> bool:
	if property == &"Animation":
		animation = value;
		notify_property_list_changed();
		return true;
	if property == &"Frame":
		frame = value;
		texture = sprites.get_frame_texture(animation, frame);
		return true;
	if property == &"Speed Scale":
		speed_scale = value;
		return true;
	return false;

func _property_can_revert(property: StringName) -> bool:
	if property == &"playing":
		return false;
	if property == &"Animation":
		return true;
	if property == &"Speed Scale":
		return true;
	if property == &"Frame":
		return true;
	return false;

func _property_get_revert(property: StringName): # -> Variant() type
	if property == &"Animation":
		return sprites.get_animation_names()[0];
	if property == &"Speed Scale":
		return 1.0;
	if property == &"Frame":
		return 0;
	return null;

func _ready():
	if sprites == null:
		return;
	is_playing.connect(on_playing);
	if autoplay:
		_playing = false;
		play();

func on_playing():
	if sprites == null or animation.is_empty():
		return;
	while _playing:
		while paused:
			await get_tree().process_frame;
		if !sprites.has_animation(animation):
			_playing = false;
			assert(false, "Animation %s not found" % animation);
			break;

		_fps = sprites.get_animation_speed(animation);
		_refresh_rate = sprites.get_frame_duration(animation, frame);

		await get_tree().create_timer((_refresh_rate/_fps)/speed_scale).timeout;
		frame += 1;
		var frame_count = sprites.get_frame_count(animation);
		if frame >= frame_count:
			frame = 0;
			if not sprites.get_animation_loop(animation):
				_playing = false;
				break;
		
		texture = sprites.get_frame_texture(animation, frame);

func _notification(what):
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		notify_property_list_changed();

func play(animation_name: String = animation):
	if !_playing:
		frame = 0;
		animation = animation_name;
		
		_playing = true;
		emit_signal("is_playing");
	else:
		paused = false;

func pause():
	paused = true;

func stop():
	frame = 0;
	_playing = false;
