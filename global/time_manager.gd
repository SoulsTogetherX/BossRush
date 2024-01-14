extends Node

signal time_scale_changed(newTime : float);

var ignore_time_scale : bool = true;
var default_time : float = 1.0;

## Allows instant [member Engine.time_scale] changes.
func instant_time_scale(scale : float = 0.0, duration : float = 0.1, audio : bool = false) -> void:
	Engine.time_scale = scale;
	if audio:
		adjust_sounds(scale);
	
	time_scale_changed.emit(scale);
	await get_tree().create_timer(duration, true, false, true).timeout;
	
	Engine.time_scale = default_time;
	if audio:
		adjust_sounds(default_time);
	
	time_scale_changed.emit(default_time);

## Allows gradual [member Engine.time_scale] transitions.[br][br]
##
## [b]NOTE[/b]: not implemented yet.
func graduale_time_scale(
			_scale : float = 0.0,
			_spd_in : float = 0.1,
			_wait : float = 0.0,
			_spd_out : float = 0.1
			) -> void:
	
	pass;

## Sets the global speed for audio.[br][br]
## 
## A wrapper for [member AudioServer.playback_speed_scale].
func adjust_sounds(scale : float) -> void:
	AudioServer.playback_speed_scale = scale;


var time : float = 0.0;
var timer_on : bool = false;

func pause(toggle : bool = true, audio : bool = false) -> void:
	if toggle:
		Engine.time_scale = 0.0;
		toggle_timer(false);
	else:
		Engine.time_scale = default_time;
		toggle_timer(true);
	
	if audio:
		adjust_sounds(Engine.time_scale);

func toggle_timer(toggle : bool = true) -> void:
	timer_on = toggle;

func reset_timer(autostart : bool = false) -> void:
	timer_on = autostart;
	time = 0.0;

func _process(delta: float) -> void:
	if timer_on && Engine.time_scale > 0:
		if ignore_time_scale:
			time += (delta / Engine.time_scale);
		else:
			time += delta;

func get_timer_raw() -> float:
	return time;

func get_miliseconds() -> int:
	return floori(fmod(time, 1) * 1000);

func get_seconds() -> int:
	return floori(fmod(time, 60));

func get_minutes(raw : bool = false) -> int:
	var ret = fmod(time, 3600);
	if raw:
		return floori(ret / 60);
	return floori(ret);

func get_hours(raw : bool = false) -> int:
	var ret = fmod(time, 216000);
	if raw:
		return floori(ret / 3600);
	return floori(ret);

func get_days(raw : bool = false) -> int:
	var ret = fmod(time, 5184000);
	if raw:
		return floori(ret / 216000);
	return floori(ret);

func get_years(raw : bool = false) -> int:
	var ret = fmod(time, 1845504000);
	if raw:
		return floori(ret / 5184000);
	return floori(ret);

func get_centuries(raw : bool = false) -> int:
	var ret = fmod(time, 1845504000000);
	if raw:
		return floori(ret / 1845504000);
	return floori(ret);

func get_timer_string(
					show_mill : bool = false,
					show_secs : bool = true,
					show_mins : bool = true,
					show_hours : bool = true,
					show_days : bool = false,
					show_years : bool = false,
					show_centuries : bool = false,
					) -> String:
	var ret : String = "";
	
	var mili  : int = floori(time * 1000);
	if show_mill:
		ret = "%03d:" % [mili % 1000];
		
	@warning_ignore("integer_division")
	var secs  : int = mili / 1000;
	if show_secs:
		ret = "%02d:" % [secs % 60] + ret;
	
	@warning_ignore("integer_division")
	var mins  : int = secs / 60;
	if show_mins:
		ret = "%02d:" % [mins % 60] + ret;
	
	@warning_ignore("integer_division")
	var hours : int = mins / 60;
	if show_hours:
		ret = "%02d:" % [hours % 60] + ret;
	
	@warning_ignore("integer_division")
	var days  : int = hours / 24;
	if show_days:
		ret = "%02d:" % [days % 24] + ret;
	
	@warning_ignore("integer_division")
	var years : int = days / 356;
	if show_years:
		ret = "%03d:" % [years % 356] + ret;
	
	@warning_ignore("integer_division")
	var cens  : int = years / 1000;
	if show_centuries:
		ret = "%03d:" % [cens % 1000] + ret;
	
	return ret.left(-1);
