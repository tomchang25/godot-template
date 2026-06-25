# tutorial_target.gd
# Optional Control target for tutorial highlight and panel placement metadata.
class_name TutorialTarget
extends Control

enum PreferredSide { AUTO, LEFT, RIGHT, TOP, BOTTOM }

@export var target_id: String = ""
@export var preferred_side: PreferredSide = PreferredSide.AUTO
@export var use_custom_rect: bool = false
@export var custom_rect: Rect2 = Rect2()


## Returns the rect Director should use for this target in global coordinates.
func get_tutorial_rect() -> Rect2:
	if use_custom_rect:
		return Rect2(global_position + custom_rect.position, custom_rect.size)
	return get_global_rect()
