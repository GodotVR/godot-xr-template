extends XRToolsPickable

export var bullet : PackedScene
export var bullet_speed : float = 10.0

var can_fire = true

func action():
	.action()
	
	if can_fire:
		_spawn_bullet()
		$ShootSound.play()
		can_fire = false
		$Cooldown.start()

func _spawn_bullet():
	if bullet:
		var new_bullet : RigidBody = bullet.instance()
		if new_bullet:
			new_bullet.set_as_toplevel(true)
			add_child(new_bullet)
			new_bullet.transform = $SpawnPoint.global_transform
			new_bullet.linear_velocity = new_bullet.transform.basis.z * bullet_speed

func _on_Cooldown_timeout():
	can_fire = true
