@tool
extends EditorInspectorPlugin
class_name SpriteInspectorPlugin
# 预览窗口引用
var previewCtrl: InspectorPeviewerCtrl


func _can_handle(object) -> bool:
	return object is SpriteFrames

func _parse_begin(object: Object) -> void:
	var script_path = get_script().resource_path
	var script_dir = script_path.get_base_dir()
	var ctrlPath = script_dir + "/preview_ctrl.tscn"
	previewCtrl = load(ctrlPath).instantiate()
	 #只处理已保存的资源
	if not object:
		return
	print("SpriteInspectorPlugin _parse_begin")
	if previewCtrl:
		previewCtrl.current_resource = object as SpriteFrames
		
	add_custom_control(previewCtrl)
		
func _parse_end(object: Object) -> void:
	if not object:
		return
	if not previewCtrl:
		return
		
	
	
