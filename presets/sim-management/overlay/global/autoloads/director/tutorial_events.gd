# tutorial_events.gd
# Semantic tutorial milestone ids. Gameplay emits these through EventBus.
class_name TutorialEvents
extends RefCounted

const CHOOSER_OPENED: StringName = &"chooser_opened"
const ACTIVITY_CHOSEN: StringName = &"activity_chosen"
const LOCATION_SELECTED: StringName = &"location_selected"
