class_name SpinePanel
extends VBoxContainer

signal advance_requested(minutes: int)
signal sample_requested

var step_one: Button
var step_fifteen: Button
var sample_button: Button
var identity: Label
var random_value: Label
var storage_label: Label
var events_label: Label


func _ready() -> void:
	add_theme_constant_override("separation", 12)
	var heading: Label = Label.new()
	heading.text = "DEVELOPER TOOLS / OPTIONAL"
	heading.add_theme_font_size_override("font_size", 22)
	add_child(heading)
	identity = Label.new()
	identity.add_theme_font_size_override("font_size", 22)
	add_child(identity)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	add_child(row)
	step_one = Button.new()
	step_one.text = "Step 1 minute"
	row.add_child(step_one)
	step_fifteen = Button.new()
	step_fifteen.text = "Step 15 minutes"
	row.add_child(step_fifteen)
	sample_button = Button.new()
	sample_button.text = "Test random draw"
	sample_button.tooltip_text = "Advances the saved test RNG stream only. Does not change cash or time."
	row.add_child(sample_button)
	random_value = Label.new()
	random_value.add_theme_font_size_override("font_size", 22)
	add_child(random_value)
	storage_label = Label.new()
	storage_label.add_theme_font_size_override("font_size", 22)
	add_child(storage_label)
	events_label = Label.new()
	events_label.add_theme_font_size_override("font_size", 22)
	add_child(events_label)
	step_one.pressed.connect(func() -> void: advance_requested.emit(1))
	step_fifteen.pressed.connect(func() -> void: advance_requested.emit(15))
	sample_button.pressed.connect(func() -> void: sample_requested.emit())


func show_spine(data: Dictionary, fingerprint: String, max_tick: int, max_id: int, max_draws: int) -> void:
	var rng: Dictionary = data["rng"]
	identity.text = "Seed %d  ·  Tick %d  ·  Next command %d\nState %s" % [
		int(rng["seed"]), int(data["tick"]), int(data["next_command"]), fingerprint.substr(0, 20),
	]
	identity.tooltip_text = "Full authoritative-state fingerprint: " + fingerprint
	var exhausted: bool = int(data["next_id"]) > max_id
	step_one.disabled = exhausted or int(data["tick"]) >= max_tick
	step_fifteen.disabled = exhausted or int(data["tick"]) > max_tick - 15
	sample_button.disabled = exhausted or int(rng["draws"]) >= max_draws
	random_value.text = "RNG ready. Errand payouts remain fixed." if int(rng["draws"]) == 0 else \
		"Test draw %d: %d  ·  Saved with this session" % [int(rng["draws"]), int(data["last_roll"])]


func show_inspection(storage: Dictionary, events: Array[Dictionary]) -> void:
	if storage.is_empty():
		storage_label.text = "Save inspection pending."
	else:
		storage_label.text = "Save: %s (v%d)  ·  Backup: %s (v%d)" % [
			storage["primary"]["status"], storage["primary"]["schema"],
			storage["backup"]["status"], storage["backup"]["schema"],
		]
	var lines: PackedStringArray = ["Recent local events (not saved history)"]
	for index: int in range(maxi(0, events.size() - 4), events.size()):
		var event: Dictionary = events[index]
		lines.append("#%d  %s  ·  minute %d" % [event["sequence"], event["type"], event["tick"]])
	if events.is_empty():
		lines.append("No events since this session was loaded or reset.")
	events_label.text = "\n".join(lines)
