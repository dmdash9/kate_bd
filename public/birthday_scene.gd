extends Node2D

@export var walk_speed: float = 200.0
@export var greeting_time: float = 17.0

@onready var mia_anim_player = $Mia/AnimationPlayer
@onready var mia = $Mia

@onready var dima_anim_player = $Dima/AnimationPlayer
@onready var dima = $Dima

@onready var greeting_timer = $GreetingTimer
@onready var mia_intro_timer = $MiaIntroTimer
@onready var dima_intro_timer = $DimaIntroTimer

var char_width = 100
var greeting_vertical_offset = 100

var mia_target_position: Vector2
var dima_target_position: Vector2

var moving: int = 0
var greeting: bool = false

var mia_intro_done: bool = false
var dima_intro_started: bool = false
var dima_intro_done: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var window_size = get_viewport_rect().size
	print("Game Window Size: ", window_size.x, "x", window_size.y)
	
	greeting_timer.connect("timeout", self.on_greeting_finished)
	mia_intro_timer.connect("timeout", self.on_mia_intro_finished)
	dima_intro_timer.connect("timeout", self.on_dima_intro_finished)
	
	# Set the target position to the center of the screen
	mia_target_position = Vector2(window_size.x / 2 - char_width, window_size.y - greeting_vertical_offset)
	dima_target_position = Vector2(window_size.x / 2 + char_width, window_size.y - greeting_vertical_offset)
	
	mia_start_intro()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !mia_intro_done:
		pass
	elif !dima_intro_started:
		dima_start_intro()
	elif !dima_intro_done:
		pass
	elif moving == 0:
		# Start the walk animation and movement
		mia_anim_player.play("walk")
		dima_anim_player.play("walk")
		$Walk.play()
		moving = 2
	elif moving > 0:
		move_towards_target(mia, mia_target_position, delta)
		move_towards_target(dima, dima_target_position, delta)
	elif !greeting:
		greeting = true
		
		$Walk.stop()
		
		mia_anim_player.play("polish_greeting")
		dima_anim_player.play("polish_greeting")
		
		$BdaySong.play()
		greeting_timer.start(greeting_time)
	
func move_towards_target(player, target_position, delta):
	var direction = (target_position - player.position).normalized()
	player.position += direction * walk_speed * delta

	if player.position.distance_to(target_position) < walk_speed * delta:
		player.position = target_position
		player.get_node("AnimationPlayer").stop()
		moving -= 1
		
func mia_start_intro():
	mia_anim_player.play("m_bday")
	$MiaIntro.play()
	mia_intro_timer.start()
	
func dima_start_intro():
	dima_intro_started = true
	dima_anim_player.play("d_bday")
	$DimaIntro.play()
	dima_intro_timer.start()
	
func on_greeting_finished():
	dima_anim_player.stop()
	mia_anim_player.stop()
	$BdaySong.stop()
	
func on_mia_intro_finished():
	mia_intro_done = true
	mia_anim_player.stop()
	$MiaIntro.stop()
	
func on_dima_intro_finished():
	dima_intro_done = true
	dima_anim_player.stop()
	$DimaIntro.stop()
