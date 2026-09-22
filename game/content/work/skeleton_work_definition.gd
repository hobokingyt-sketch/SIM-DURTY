class_name SkeletonWorkDefinition
extends Resource

@export var activity_id: StringName = &"skeleton_errand"
@export var display_name: String = "Run an errand"
@export var payout_cents: int = 500
@export var duration_minutes: int = 15


func is_valid_definition() -> bool:
	return not String(activity_id).is_empty() \
		and not display_name.is_empty() \
		and payout_cents >= 0 and payout_cents <= 1000000 \
		and duration_minutes > 0 and duration_minutes <= 1440
