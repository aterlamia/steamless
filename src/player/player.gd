extends CharacterBody3D

var gravity = Vector3.DOWN * 12  # strength of gravity
var speed = 8  
var jump_speed = 6 
var hop_speed = 3.5 
var spin = 0.05
var camera_spin = 1

var jump = false
var hop = false
var model: Node3D
var modelAnimation: AnimationPlayer
var cameraController: Node3D

var actionFinder: RayCast3D
var curbCheckerBottom: RayCast3D
var curbCheckerTop: RayCast3D

var hasCurbTop = false
var hasCurbBottom = false

var beforeCurb = false

func _ready() -> void:
	model = get_node("PlayerModel")
	modelAnimation = get_node("PlayerModel/AnimationPlayer")
	cameraController = get_node("CameraController")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	modelAnimation.play("loop_idle")
	modelAnimation.playback_speed = 1.0
	actionFinder = get_node("ActionFinder")
	curbCheckerBottom = get_node("CurbCheckerBottom")
	curbCheckerTop = get_node("CurbCheckerTop")

	
func checkCurb():
	hasCurbTop = false
	hasCurbBottom = false	
	
	if curbCheckerBottom.is_colliding():
		var obj = curbCheckerBottom.get_collider()
		print("top: ", obj.get_name())
		hasCurbBottom = true
	if curbCheckerTop.is_colliding():
		var obj = curbCheckerTop.get_collider()
		print("bottom: ", obj.get_name())
		hasCurbTop = true

	if !hasCurbTop and hasCurbBottom:
		beforeCurb = true
	else:
		beforeCurb = false

func checkAction() -> void:
	if actionFinder.is_colliding():
		var obj = actionFinder.get_collider()
		print("action: ", obj.get_name())

func playAnimation() -> void:
	if (jump):
		modelAnimation.playback_speed = 1.0
		modelAnimation.play("Jump")
		return
	elif(velocity.y > 0):
		return
	elif(velocity.y < 0 and not is_on_floor()):
		modelAnimation.playback_speed = 1.0
		modelAnimation.play("fall")
		return
	
	
	# if velocity is forward play forward animation
	if(velocity.z > 0):
		modelAnimation.play("Run")
		modelAnimation.playback_speed = 3.0
	elif(velocity.z < 0):
		modelAnimation.play("Run")
		modelAnimation.playback_speed = 3.0
	else:
		modelAnimation.play("loop_idle")
		modelAnimation.playback_speed = 1.0

func get_input():
	var vy = velocity.y
	velocity = Vector3()
	hop = false
	if Input.is_action_pressed("move_forward"):
		velocity += transform.basis.z * speed	
		if (beforeCurb):
			hop = true

	if Input.is_action_pressed("move_back"):
		velocity += -transform.basis.z * speed

	if Input.is_action_pressed("turn_left"):
		rotate_y(-lerpf(0, spin, -1))

	if Input.is_action_pressed("turn_right"):
		rotate_y(-lerpf(0, spin, 1))
		

	velocity.y = vy
	jump = false
	if Input.is_action_just_pressed("jump"):
		jump = true
	playAnimation()
	pass
	
func _physics_process(delta):
	velocity += gravity * delta
	if jump and is_on_floor():
		velocity.y = jump_speed

	if hop and is_on_floor():
		velocity.y = hop_speed
	checkCurb()
	checkAction()
	get_input()
	move_and_slide()
	

func _unhandled_input(event):

	if event is InputEventMouseMotion:
		# check if mouse is down
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):	
			if event.relative.x > 0:
				cameraController.rotate_y(-lerpf(0, spin, event.relative.x/10))
			elif event.relative.x < 0:
				cameraController.rotate_y(-lerpf(0, spin, event.relative.x/10))
	pass
