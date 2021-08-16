extends Spatial

enum STATE{
  stand,
  walk
}
enum SIDE{
  L,
  R
}

var h_hips=0.9
var crouch=0.2

var skel: Skeleton=null
var b_thigh=[null,null]
var b_foot=[null,null]
var node_foot=[null,null]
var gpos_foot=[null,null]
var adjust_foot=[Vector3(0,0.07,0),Vector3(0,0.07,0)]
var t=0.0

func _ready():
	skel=$"humanlowpoly/humanlowpoly/"
	b_thigh[SIDE.R]=skel.find_bone("thigh_r")
	b_thigh[SIDE.L]=skel.find_bone("thigh_l")	
	b_foot[SIDE.R]=skel.find_bone("foot_r")
	b_foot[SIDE.L]=skel.find_bone("foot_l")		
	node_foot[SIDE.L]=$"humanlowpoly/pos_foot_l1"
	node_foot[SIDE.R]=$"humanlowpoly/pos_foot_r1"
	gpos_foot[SIDE.L]=Vector3(0.12,0.07,0)
	gpos_foot[SIDE.R]=Vector3(-0.12,0.07,0)		

	#$"humanlowpoly/humanlowpoly/IK_foot_r".start()
	update_feet()
	
	
	
			
func _process(delta):
	t+=delta
	crouch=((sin(t)+1.0)/2.0)*0.5+0.075
	update_feet()
	
	#var pr=skel.to_global(skel.get_bone_global_pose(b_foot[SIDE.R]).origin)
	#node_foot[SIDE.R].translation.y+=pr.y-self.to_global(node_foot[SIDE.R].translation).y
	#update_ik()
	#pr=skel.to_global(skel.get_bone_global_pose(b_foot[SIDE.R]).origin)
	#update_ik()
	
	
	#var T=skel.get_bone_custom_pose(thigh_r)
	#T=T.rotated(Vector3(1,0,0),PI*delta)
	#skel.set_bone_custom_pose(thigh_r, T)
	#get_node("../camera_pivot").translation.z=self.translation.z	
	#if Input.is_action_just_pressed("ui_down"):
		#skel.set_bone_pose(thigh_r, Transform.IDENTITY)
		#print(skel.get_bone_global_pose(foot_r))
		##print($humanlowpoly/humanlowpoly/ba_foot_r/foot_r1.to_global(Vector3(0,0,0)))
		#skel.set_bone_pose(thigh_r, Transform.IDENTITY.rotated(Vector3(1,0,0),deg2rad(30.0)))
		#print(skel.get_bone_global_pose(foot_r))
		##print($humanlowpoly/humanlowpoly/ba_foot_r/foot_r1.to_global(Vector3(0,0,0)))
#	if Input.is_action_just_pressed("ui_down"):
#		$"humanlowpoly/pos_foot_r1".translation=Vector3(-0.14,0.058,0)
#		$"humanlowpoly/humanlowpoly/IK_foot_r".stop()
#		$"humanlowpoly/humanlowpoly/IK_foot_r".start(true)
#		$"humanlowpoly/humanlowpoly/IK_foot_r".start()
#
#		print(skel.get_bone_global_pose(b_foot[SIDE.R]))
#
#		$"humanlowpoly/pos_foot_r1".translation+=Vector3(0,0.5,0)
#		$"humanlowpoly/humanlowpoly/IK_foot_r".stop()
#		$"humanlowpoly/humanlowpoly/IK_foot_r".start(true)
#		$"humanlowpoly/humanlowpoly/IK_foot_r".start()
#
#		print(skel.get_bone_global_pose(b_foot[SIDE.R]))

func update_ik():
	$"humanlowpoly/humanlowpoly/IK_foot_l".stop()
	$"humanlowpoly/humanlowpoly/IK_foot_r".stop()
	$"humanlowpoly/humanlowpoly/IK_foot_l".start(true)
	#$"humanlowpoly/humanlowpoly/IK_foot_l".start()
	$"humanlowpoly/humanlowpoly/IK_foot_r".start(true)
	#$"humanlowpoly/humanlowpoly/IK_foot_r".start()
	

func update_feet():
	self.translation=Vector3((gpos_foot[SIDE.L]+gpos_foot[SIDE.R])/2)
	self.translation.y=min(gpos_foot[SIDE.L].y,gpos_foot[SIDE.R].y)-crouch
	update_ik()
	node_foot[SIDE.L].translation=self.to_local(gpos_foot[SIDE.L]+adjust_foot[SIDE.L])
	node_foot[SIDE.R].translation=self.to_local(gpos_foot[SIDE.R]+adjust_foot[SIDE.R])
	update_ik()
	var pr=skel.to_global(skel.get_bone_global_pose(b_foot[SIDE.R]).origin)
	var pl=skel.to_global(skel.get_bone_global_pose(b_foot[SIDE.L]).origin)
	var maxquant=10
	var quant=0
	while ((abs(pr.y-gpos_foot[SIDE.R].y))>0.001) and (quant<maxquant):
		node_foot[SIDE.R].translation.y-=pr.y-gpos_foot[SIDE.R].y
		update_ik()
		update_ik()
		pr=skel.to_global(skel.get_bone_global_pose(b_foot[SIDE.R]).origin)		
		update_ik()
		quant+=1
	print(quant)
	#quant=0
	#while ((pl-self.to_global(node_foot[SIDE.L].translation)).length()>0.001) and (quant<maxquant):
		#node_foot[SIDE.L].translation+=pl-self.to_global(node_foot[SIDE.L].translation)
		#pl=skel.to_global(skel.get_bone_global_pose(b_foot[SIDE.L]).origin)
		#update_ik()
		#quant+=1


