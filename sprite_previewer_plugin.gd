@tool
extends EditorPlugin
class_name SpritePreviewerPlugin

# 预览器实例
var previewerWin: Window
var sprite_frames_inspector: SpriteInspectorPlugin

func _enter_tree():

	# 创建预览器实例
	var script_path = get_script().resource_path
	var script_dir = script_path.get_base_dir()
	var preview_scene_path = script_dir + "/Window/AnimationPreview.tscn"
	previewerWin = load(preview_scene_path).instantiate() 

	# 将预览器添加到编辑器界面
	get_editor_interface().get_base_control().add_child(previewerWin)

	# 添加工具栏按钮
	add_tool_menu_item("SpriteFrames previewer", _open_previewer)

	previewerWin.close_requested.connect(_on_close_requested)
	# 隐藏预览器直到需要显示
	previewerWin.hide()
	
	######################
	### 绑定 Inspector 插件
	# 创建 SpriteFrames 预览器插件
	######################

	
	var inspectorPath = script_dir + "/Inspector/sprite_inspector_plugin.gd"
	sprite_frames_inspector = load(inspectorPath).new()
	
	add_inspector_plugin(sprite_frames_inspector)

func _exit_tree():
	# 清理操作
	remove_tool_menu_item("SpriteFrames Previewer")
	remove_inspector_plugin(sprite_frames_inspector)
	if previewerWin:
		previewerWin.queue_free()
		previewerWin = null

# 打开预览器的回调函数
func _open_previewer():
	previewerWin.show()
	previewerWin.popup_centered_ratio(0.8)

# 获取插件名称
func _get_plugin_name():
	return "SpriteFrames Previewer"
	
	
func _on_close_requested():
	print("关闭预览器")
	previewerWin.hide()
	
