extends Spatial


var estado_rampa=0
var oldz=0
var t=0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t+=delta
	#$rampa.rotation.z=sin(t)*0.2
	if Input.is_action_just_pressed("ui_accept"):
		if $camera_pivot/Camera.current==false:
			$camera_pivot/Camera.current=true
			$camera_pivot2/Camera.current=false
		else:
			$camera_pivot2/Camera.current=true
			$camera_pivot/Camera.current=false
	$camera_pivot.translation=$char.ref_ground+Vector3(0,1.0,0)
	$camera_pivot2.translation=$char.ref_ground+Vector3(0,1.0,0)
	update_markers()
			

			
func update_markers():
	$meshp1.translation=to_local($char.gpos_foot[0]-Vector3(0,0,0.5))
	$meshp2.translation=to_local($char.gpos_foot[1]-Vector3(0,0,0.6))
