extends Spatial

enum STATE{
  stand,
  walk
}
enum SIDE{
  L,
  R
}
const GROUND_ANG=Vector3(-1000,-1000,-1000)

var h_hips=0.9
var crouch=0.2
var crouch_min=0.1
var center=Vector3(0,0,0)
var ref_ground=Vector3(0,0,0)
var pass_swing_front=0.0
var skel: Skeleton=null
var b_thigh=[null,null]
var b_foot=[null,null]
var node_foot=[null,null]
var gpos_foot=[null,null]
var adjust_foot=[Vector3(0,0.07,0),Vector3(0,0.07,0)]
var t=0.0
var ray_v:RayCast=null
var model:Spatial=null
var foot_points=[[null,null,null,null],[null,null,null,null]]

#foot animation
var pass_dist=0.75
var pass_sidedist=0.17
var pass_height=0.25
var pass_time=1.0#1.0
var anim_pos_foot=[[],[]]
var anim_ang_foot=[[],[]]
var anim_crouch=[]
var anim_t=[]
var anim_side=0
var anim_center=[]
var last_ang_ground=[0.0,0.0]
#--------------------
var pass_t=0.0
#-------------------



func _ready():
	ray_v=$humanlowpoly/ray_v
	model=$humanlowpoly
	skel=$humanlowpoly/humanlowpoly/Skeleton
	b_thigh[SIDE.R]=skel.find_bone("thigh_r")
	b_thigh[SIDE.L]=skel.find_bone("thigh_l")	
	b_foot[SIDE.R]=skel.find_bone("foot_r")
	b_foot[SIDE.L]=skel.find_bone("foot_l")		
	node_foot[SIDE.L]=$"humanlowpoly/pos_foot_l1"
	node_foot[SIDE.R]=$"humanlowpoly/pos_foot_r1"
	gpos_foot[SIDE.L]=Vector3(0.12,0.07+1,self.translation.z)
	gpos_foot[SIDE.R]=Vector3(-0.12,0.07+1,self.translation.z)	
	
	foot_points[SIDE.L][0]=$humanlowpoly/humanlowpoly/Skeleton/ba_foot_l/foot_l1
	foot_points[SIDE.L][1]=$humanlowpoly/humanlowpoly/Skeleton/ba_foot_l/foot_l2
	foot_points[SIDE.L][2]=$humanlowpoly/humanlowpoly/Skeleton/ba_foot_l/foot_l3
	foot_points[SIDE.L][3]=$humanlowpoly/humanlowpoly/Skeleton/ba_foot_l/foot_l4
	foot_points[SIDE.R][0]=$humanlowpoly/humanlowpoly/Skeleton/ba_foot_r/foot_r1
	foot_points[SIDE.R][1]=$humanlowpoly/humanlowpoly/Skeleton/ba_foot_r/foot_r2
	foot_points[SIDE.R][2]=$humanlowpoly/humanlowpoly/Skeleton/ba_foot_r/foot_r3
	foot_points[SIDE.R][3]=$humanlowpoly/humanlowpoly/Skeleton/ba_foot_r/foot_r4
	
	update_feet()
	rest_on_ground()
	update_feet()
	pass_time=0.25+((100.0-$slider_pass_speed.value)/100.0)*2
	pass_dist=0.25+(($slider_pass_length.value)/99.0)*0.8
	print(pass_dist)
	generate_pass(anim_side)
	
	
			
func _process(delta):
	t+=delta	

	if t<2.0:
		rest_on_ground()
		generate_pass(anim_side,true)
	else:
		process_pass(delta)
	
	update_feet()
	ray_v.translation=Vector3(0,2,0)
	ray_v.force_raycast_update()
	if ray_v.is_colliding():
		ref_ground=ray_v.get_collision_point()
	if translation.z>90:
		gpos_foot[SIDE.L]=Vector3(0.12,0.07+1,0)
		gpos_foot[SIDE.R]=Vector3(-0.12,0.07+1,0)	
		rest_on_ground()
		generate_pass(anim_side)

	
	

func update_ik():
	$"humanlowpoly/humanlowpoly/Skeleton/IK_foot_r".stop()
	$"humanlowpoly/humanlowpoly/Skeleton/IK_foot_l".stop()
	$"humanlowpoly/humanlowpoly/Skeleton/IK_foot_r".start(true)
	$"humanlowpoly/humanlowpoly/Skeleton/IK_foot_l".start(true)
	

func update_feet():
	self.translation=Vector3((gpos_foot[SIDE.L]+gpos_foot[SIDE.R])/2)+self.center
	self.translation.y=min(gpos_foot[SIDE.L].y,gpos_foot[SIDE.R].y)-crouch
	node_foot[SIDE.L].translation=self.to_local(gpos_foot[SIDE.L]+adjust_foot[SIDE.L])
	node_foot[SIDE.R].translation=self.to_local(gpos_foot[SIDE.R]+adjust_foot[SIDE.R])
	update_ik()
	
	for side in range(2):
		var p=skel.to_global(skel.get_bone_global_pose(b_foot[side]).origin)
		var maxquant=4
		var quant=0
		while (((p-gpos_foot[side]).length())>0.001) and (quant<maxquant): 
			node_foot[side].translation-=p-gpos_foot[side]
			update_ik()
			p=skel.to_global(skel.get_bone_global_pose(b_foot[side]).origin)		
			quant+=1

		
func calc_foot_ground_angle(side,gpos=null):
	if gpos==null:
		gpos=gpos_foot[side]
	ray_v.translation=model.to_local(foot_points[side][0].to_global(Vector3(0,0,0))+Vector3(0,1.5,0)+(gpos-gpos_foot[side]))
	ray_v.force_raycast_update()
	var p1=null
	if ray_v.is_colliding():
		p1=ray_v.get_collision_point()
	ray_v.translation=model.to_local(foot_points[side][1].to_global(Vector3(0,0,0))+Vector3(0,1.5,0)+(gpos-gpos_foot[side]))
	ray_v.force_raycast_update()
	var p2=null
	if ray_v.is_colliding():
		p2=ray_v.get_collision_point()
	var angx=(p2-p1).angle_to(Vector3(p2.x,p1.y,p2.z)-p1)
	if p2.y<p1.y:
		angx=-angx
		
	ray_v.translation=model.to_local(foot_points[side][2].to_global(Vector3(0,0,0))+Vector3(0,1.5,0)+(gpos-gpos_foot[side]))
	ray_v.force_raycast_update()
	p1=null
	if ray_v.is_colliding():
		p1=ray_v.get_collision_point()
	ray_v.translation=model.to_local(foot_points[side][3].to_global(Vector3(0,0,0))+Vector3(0,1.5,0)+(gpos-gpos_foot[side]))
	ray_v.force_raycast_update()
	p2=null
	if ray_v.is_colliding():
		p2=ray_v.get_collision_point()
	var angz=(p2-p1).angle_to(Vector3(p2.x,p1.y,p2.z)-p1)
	if p2.y<p1.y:
		angz=-angz
	
	return Vector3(angx,0,angz)

func set_foot_angle(side,ang):
	node_foot[side].rotation=ang
	update_ik()

func rest_on_ground():
	crouch=0.08
	center=Vector3(0,0,0)
	for side in range(2):
		var pf1=gpos_foot[side]+Vector3(0,2.5,0)
		ray_v.translation=model.to_local(pf1)	
		ray_v.force_raycast_update()
		if ray_v.is_colliding():
			gpos_foot[side].y=ray_v.get_collision_point().y+adjust_foot[side].y	
		
		
func teste1(delta):
	t+=delta
	crouch=((sin(t)+1.0)/2.0)*0.5+crouch_min
	center.x=sin(t*3)*0.1
	center.z=sin(t*3)*0.1
	

	gpos_foot[SIDE.R].z=sin(t)*0.3
	rest_on_ground()
	update_feet()
	set_foot_angle(SIDE.L,calc_foot_ground_angle(SIDE.L))
	set_foot_angle(SIDE.R,calc_foot_ground_angle(SIDE.R))


func calc_ground_pos(vpos):
	ray_v.translation=self.to_local(vpos)+Vector3(0,2,0)
	ray_v.force_raycast_update()
	return ray_v.get_collision_point()
	
func generate_pass(side,first=false):
	var side2=1-side
	var dir=(self.to_global(Vector3(0,0,1))-self.to_global(Vector3(0,0,0))).normalized()
	var dside=self.to_global(Vector3(1,0,0)*(side*2-1)*(-pass_sidedist))-self.to_global(Vector3(0,0,0))
	var next_pos=calc_ground_pos(gpos_foot[side2]+dir*pass_dist+dside)+adjust_foot[side]	
	dir=(next_pos-gpos_foot[side]).normalized()
	next_pos=calc_ground_pos(gpos_foot[side2]+dir*pass_dist+dside)+adjust_foot[side]
	anim_pos_foot[side]=[]	
	var mid_point=(gpos_foot[side]+next_pos)/2.0+Vector3(0,pass_height,0)
	anim_pos_foot[side].append(gpos_foot[side])
	anim_pos_foot[side].append(mid_point*0.2+gpos_foot[side]*0.8+Vector3(0,pass_height*0.3,0))
	anim_pos_foot[side].append(mid_point*0.4+gpos_foot[side]*0.6+Vector3(0,pass_height*0.3,0))
	anim_pos_foot[side].append(mid_point)
	anim_pos_foot[side].append(mid_point*0.4+next_pos*0.6+Vector3(0,pass_height*0.0,0))
	anim_pos_foot[side].append(mid_point*0.2+next_pos*0.8+Vector3(0,pass_height*0.0,0))
	anim_pos_foot[side].append(next_pos)
	anim_pos_foot[side2]=[]
	anim_pos_foot[side2].append(gpos_foot[side2])
	anim_pos_foot[side2].append(gpos_foot[side2])
	anim_pos_foot[side2].append(gpos_foot[side2])
	anim_pos_foot[side2].append(gpos_foot[side2])
	anim_pos_foot[side2].append(gpos_foot[side2])
	anim_pos_foot[side2].append(gpos_foot[side2]+Vector3(0.0,0.05,0.0))
	anim_pos_foot[side2].append(gpos_foot[side2]+Vector3(0.0,0.1,0.0))
	anim_ang_foot[side]=[]	
	anim_ang_foot[side].append(Vector3(deg2rad(45),0,0))
	anim_ang_foot[side].append(Vector3(deg2rad(60),0,0))
	anim_ang_foot[side].append(Vector3(deg2rad(70),0,0))
	anim_ang_foot[side].append(Vector3(deg2rad(40),0,0))
	anim_ang_foot[side].append(Vector3(deg2rad(0),0,0))
	anim_ang_foot[side].append(Vector3(deg2rad(-10),0,0))
	anim_ang_foot[side].append(GROUND_ANG)	
	anim_ang_foot[side2]=[]
	anim_ang_foot[side2].append(GROUND_ANG)
	anim_ang_foot[side2].append(GROUND_ANG)
	anim_ang_foot[side2].append(GROUND_ANG)
	anim_ang_foot[side2].append(GROUND_ANG)
	anim_ang_foot[side2].append(GROUND_ANG)
	anim_ang_foot[side2].append(Vector3(deg2rad(20),0,0))
	anim_ang_foot[side2].append(Vector3(deg2rad(40),0,0))
	

	anim_crouch=[0.15,0.15,0.14,0.12,0.14,0.235-0.04,0.15]
	var dirf=(self.to_global(Vector3(0,0,1))-self.to_global(Vector3(0,0,0))).normalized()
	anim_center=[dirf*0.1,dirf*0.1,dirf*0.1,dirf*0.1,dirf*0.1,dirf*0.1,dirf*0.1]
	if first:
		anim_crouch[0]=0.08
		anim_center[0]=Vector3(0,0,0)

	anim_t=[0.0,0.1*pass_time,0.2*pass_time,0.5*pass_time,0.8*pass_time,0.9*pass_time,pass_time]

func process_pass(delta):
	if anim_t.size()>1:
		pass_t+=delta
		var i=0
		while anim_t[i+1]<pass_t and (i+1)<(anim_t.size()-1):
			i+=1		
		
		var vt=pass_t
		if pass_t>=anim_t[anim_t.size()-1]:
			vt=anim_t[anim_t.size()-1]
			
		var f=(vt-anim_t[i])/(anim_t[i+1]-anim_t[i])
		
		for side in range(2):			
			gpos_foot[side]=anim_pos_foot[side][i]+(anim_pos_foot[side][i+1]-anim_pos_foot[side][i])*f
			
		for side in range(2):
			var ang1=anim_ang_foot[side][i]
			if ang1==GROUND_ANG:
				ang1=calc_foot_ground_angle(side)
			var ang2=anim_ang_foot[side][i+1]
			if ang2==GROUND_ANG:
				ang2=calc_foot_ground_angle(side)			
			set_foot_angle(side,ang1+(ang2-ang1)*f)
		
			
		crouch=anim_crouch[i]+(anim_crouch[i+1]-anim_crouch[i])*f	
		center=anim_center[i]+(anim_center[i+1]-anim_center[i])*f
		if pass_t>=anim_t[anim_t.size()-1]:
			pass_t=0
			anim_side=1-anim_side
			generate_pass(anim_side)


func _on_slider_pass_speed_value_changed(value):
	pass_time=0.25+((100.0-value)/100.0)*2


func _on_slider_pass_speed2_value_changed(value):
	pass_dist=0.25+((value)/99.0)*0.8
