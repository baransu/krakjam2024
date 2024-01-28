class_name Staff
extends CharacterBody2D

signal state_changed

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var decision_timer: Timer = $DecisionTimer
@export var movement_speed: float = 100.0
@onready var state_label: Label = %StateLabel
@export var smoke_time := 15.0
@onready var sprite: Sprite2D = $Sprite2D
@onready var szlug: Node2D = %Szlug
@onready var status_icon: TextureRect = %StatusIcon

@export var idle_icon: Texture2D
@export var checkout_icon: Texture2D
@export var smoke_icon: Texture2D
@export var hotdog_icon: Texture2D

enum State { IDLE, REFILL, CHECKOUT, HOTDOG, SMOKE }
var state = State.CHECKOUT
var target: Building
var staff_res: StaffRes


func _ready() -> void:
	szlug.hide()
	nav_agent.velocity_computed.connect(on_velocity_computed)
	nav_agent.navigation_finished.connect(on_nav_finished)
	GameState.building_destroyed.connect(on_building_destroyed)
	decision_timer.timeout.connect(on_decision_timer_timeout)
	change_state(State.IDLE)


func on_decision_timer_timeout() -> void:
	if state == State.IDLE:
		change_state(State.CHECKOUT)
		find_target(Building.Type.CHECKOUT)

	if state == State.CHECKOUT && randf() < 0.02:
		change_state(State.SMOKE)
		var smoke = get_tree().get_first_node_in_group("smoke")
		nav_agent.set_target_position(smoke.global_position)


func start_refill(building: Building) -> void:
	change_state(State.REFILL)
	target = building
	nav_agent.set_target_position(target.get_front())


func on_building_destroyed(building: Building) -> void:
	if building == target:
		target = null
		nav_agent.set_target_position(global_position)
		await get_tree().create_timer(1).timeout
		find_target(Building.Type.CHECKOUT)


func on_nav_finished() -> void:
	match state:
		State.REFILL:
			if target is ProductBuilding:
				await target.interact_staff(self)

			change_state(State.CHECKOUT)
			find_target(Building.Type.CHECKOUT)

		State.CHECKOUT:
			change_state(State.CHECKOUT)
			if target is CheckoutBuilding:
				target.staff_arrived(self)

		State.SMOKE:
			szlug.show()
			await get_tree().create_timer(smoke_time).timeout
			szlug.hide()
			change_state(State.CHECKOUT)
			find_target(Building.Type.CHECKOUT)

		_:
			pass


func find_target(type: Building.Type) -> void:
	target = GameState.get_building_for_staff(type)
	if is_instance_valid(target):
		var pos = Vector2.ZERO
		if type == Building.Type.CHECKOUT:
			pos = target.get_back()
		else:
			pos = target.get_front()

		nav_agent.set_target_position(pos)
	else:
		change_state(State.IDLE)


func _physics_process(_delta: float):
	if nav_agent.is_navigation_finished():
		return
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		on_velocity_computed(new_velocity)


func on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func change_state(next_state: State) -> void:
	if (
		state == State.CHECKOUT
		&& next_state != State.HOTDOG
		&& next_state != state
		&& target is CheckoutBuilding
	):
		target.staff_left()

	state = next_state
	state_changed.emit()
	match state:
		State.IDLE:
			state_label.text = "IDLE"

		State.REFILL:
			state_label.text = "REFILL"

		State.CHECKOUT:
			state_label.text = "CHECKOUT"

		State.SMOKE:
			state_label.text = "SMOKE"

		State.HOTDOG:
			state_label.text = "HOTDOG"

		_:
			pass

	match state:
		State.IDLE:
			status_icon.texture = idle_icon

		State.REFILL:
			if target is ProductBuilding:
				status_icon.texture = target.res.icon

		State.CHECKOUT:
			status_icon.texture = checkout_icon

		State.SMOKE:
			status_icon.texture = smoke_icon

		State.HOTDOG:
			status_icon.texture = hotdog_icon


func something_hotdog() -> void:
	change_state(Staff.State.HOTDOG)
	anim_player.play("hotdog")
	await get_tree().create_timer(anim_player.current_animation_length).timeout
	change_state(Staff.State.CHECKOUT)


func set_res(res: StaffRes) -> void:
	staff_res = res
	sprite.texture = res.texture
