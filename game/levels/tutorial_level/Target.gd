extends Spatial

func _on_Area_body_entered(body):
	# we've been hit by a bullet, free our bullet
	body.queue_free()
	
	# place sound and play it
	$HitSound.transform = $Area.transform
	$HitSound.play()
	
	# move our target
	$Area.transform.origin = Vector3(rand_range(-1.0, 1.0), rand_range(-0.5, 0.5), 0.0)
