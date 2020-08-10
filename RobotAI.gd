extends KinematicBody


## variable definitions for the AI

var gravity = Vector3.DOWN * 12
var speed: int = 15
var jump_speed: int = 6
#states for movement and for randomising turning while
#looking forward
var state: int = 0
var fstate: int = 0

#the three rays attached to the robot
onready var ray0 = $Raymaster/objectcaster_0/MeshInstance/RayCast
onready var ray45 = $Raymaster/objectcaster_45/MeshInstance/RayCast
onready var ray90 = $Raymaster/objectcaster_90/MeshInstance/RayCast
onready var ray045 = $Raymaster/objectcaster_045/MeshInstance/RayCast
onready var ray090 = $Raymaster/objectcaster_090/MeshInstance/RayCast


var velocity = Vector3()
var ismoving: bool = false
var is_dead: bool = false
var is_moving = false
var anim_player


var rotationValue
var moveForward
var rotate_left
var rotate_right
#speed at which ai rotates
var rotspeed: int = 4
var life: int = 1


func _process(delta):
	pass

func Hurt():
	#life = life-1
	#print(life)
	#if life == 0:
	#	Death()
	print("hit")



func Death():
	is_dead = true
	is_moving = false
	$CollisionShape.disabled = false
	velocity.x = 0
	velocity.z = 0
	yield(get_tree().create_timer(0.1), "timeout")
	
	print("Robot collision")


func _physics_process(delta):
	
	
	velocity += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	anim_player = get_node("AnimationPlayer")
	var anim_to_play = "Robot_Idle"
	
	if is_moving:
		anim_to_play = "Robot_Running"
	
	var current_anim = anim_player.get_current_animation()
	
	if current_anim != anim_to_play:
		anim_player.play(anim_to_play)

## this function defines what movement is

	if is_dead == false:
		#left
		#if state == 0:
		#	rotationValue = rotspeed*delta
		#	rotate_y(rotationValue)
		#	is_moving = true
		#right
		#elif state == 1:
		#	rotationValue = -rotspeed*delta
		#	rotate_y(rotationValue)
		#	is_moving = true
		#forward. only forward is active because i only need forward for now
		if state == 2:
			translate(Vector3(0,0,speed*delta))
			is_moving = true
		#backwards
		#elif state == 3:
		#	velocity.z = -speed
		#	is_moving = true
		else:
			velocity.x = 0
			velocity.z = 0
			is_moving = false


		# write script to adjust rotspeed to allow ai to turn faster

		#ray 0 degrees forward and changing raynums value in another scripts to be referred to by the gui
		# ray -45 degrees right
		# ray -90 degrees right
		# ray 45 degrees left
		# ray 90 degrees left
		
		
		
		var ray0_origin = ray0.global_transform.origin
		var ray0_collision_point = ray0.get_collision_point()
		var ray0_distance = ray0_origin.distance_to(ray0_collision_point)
		
		# ray -45 degrees right
		var ray045_origin = ray045.global_transform.origin
		var ray045_collision_point = ray045.get_collision_point()
		var ray045_distance = ray045_origin.distance_to(ray045_collision_point)
		# ray -90 degrees right
		var ray090_origin = ray090.global_transform.origin
		var ray090_collision_point = ray090.get_collision_point()
		var ray090_distance = ray090_origin.distance_to(ray090_collision_point)
		# ray 45 degrees left
		var ray45_origin = ray45.global_transform.origin
		var ray45_collision_point = ray45.get_collision_point()
		var ray45_distance = ray45_origin.distance_to(ray45_collision_point)
		# ray 90 degrees left
		var ray90_origin = ray90.global_transform.origin
		var ray90_collision_point = ray90.get_collision_point()
		var ray90_distance = ray90_origin.distance_to(ray90_collision_point)
		
		var fitscore = ((ray0_distance + ray045_distance + ray090_distance + ray45_distance + ray90_distance)/5)

		
		#display numbers on screen
		$VBoxContainer/fitscore.text = str("Fitscore: ")+str(fitscore)
		$VBoxContainer/ray0text.text = str("ray0: ")+str(ray0_distance)
		$VBoxContainer/ray045text.text = str("ray045: ")+str(ray045_distance)
		$VBoxContainer/ray090text.text = str("ray090: ")+str(ray090_distance)
		$VBoxContainer/ray45text.text = str("ray45: ")+str(ray45_distance)
		$VBoxContainer/ray90text.text = str("ray90: ")+str(ray90_distance)
		
		
#		fit score is an average of all 5 ray distances converted to a percentage, the closer to 1, the further away from the wall
		var fit_score = fitscore
		#print(fit_score)
		var acc_dist = 8

		if ray0_distance <= acc_dist and fstate == 1:
			rotationValue = -rotspeed*delta
			rotate_y(rotationValue)
		elif ray0_distance <= acc_dist and fstate == 2:
			rotationValue = rotspeed*delta
			rotate_y(rotationValue)

		if ray045_distance <= acc_dist:
			rotationValue = rotspeed*delta
			rotate_y(rotationValue)

		if ray090_distance <= acc_dist:
			rotationValue = rotspeed*delta
			rotate_y(rotationValue)

		if ray45_distance <= acc_dist:
			rotationValue = -rotspeed*delta
			rotate_y(rotationValue)

		if ray90_distance <= acc_dist:
			rotationValue = -rotspeed*delta
			rotate_y(rotationValue)



## if the player enters the enemy damage area2d
## then run func Hurt which is located in the 
## player.gd file
		
func _on_PlayerDamage_body_entered(body):
	if "Robot" in body.name:
		body.Hurt()

## if the player enters the player damage area2d
## then run the func Death which is located in the
## walkerai.gd file 

func _on_EnemyDamage_body_entered(body):
	if "Robot" in body.name:
		body.enemy_jump()
		Death()



func _on_Timer_timeout():
	state = floor(rand_range(2,2))
	fstate = floor(rand_range(1,3))



