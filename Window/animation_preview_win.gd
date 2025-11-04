@tool
extends Window
class_name AnimationPreviewWin

# 主要节点引用
@export
@onready var folder_button: Button
@export
@onready var folder_label: Label
@export
@onready var include_children_folder: CheckBox
@export
@onready var anim_list: OptionButton
@export
@onready var sprite: AnimatedSprite2D
@export
@onready var index_label: Label
@export
@onready var prev_button: Button
@export
@onready var next_button: Button

# 资源管理
var sprite_frames_list = []
var current_index := -1

func _ready():
	# 设置窗口属性
	title = "SpriteFrames 预览器"
	size = Vector2i(600, 500)
	min_size = Vector2i(400, 300)

	# 设置复选框状态
	include_children_folder.button_pressed = true

	# 连接信号
	folder_button.pressed.connect(_on_select_folder_pressed)
	prev_button.pressed.connect(_prev_sprite_frame)
	next_button.pressed.connect(_next_sprite_frame)
	anim_list.item_selected.connect(_on_animation_selected)
	include_children_folder.toggled.connect(_on_include_children_changed)

func _on_include_children_changed(enabled: bool):
	# 当复选框状态改变时，重新加载资源
	if folder_label.text != "":
		_load_sprite_frames(folder_label.text)

func _on_select_folder_pressed():
	# 创建并显示文件对话框
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.dir_selected.connect(_on_folder_selected)
	# 设置到资源目录
	if DirAccess.dir_exists_absolute("res://"):
		dialog.current_dir = "res://"

	add_child(dialog)
	dialog.popup_centered_ratio(0.6)

func _on_folder_selected(path):
	folder_label.text = path
	_load_sprite_frames(path)

func _load_sprite_frames(path):
	# 重置状态
	sprite_frames_list = []
	current_index = -1
	index_label.text = "0/0"
	prev_button.disabled = true
	next_button.disabled = true
	anim_list.clear()
	anim_list.add_item("选择动画...", 0)
	anim_list.select(0)
	sprite.sprite_frames = null

	if not DirAccess.dir_exists_absolute(path):
		print_debug("目录不存在: ", path)
		return

	var include_subfolders = include_children_folder.button_pressed

	print("开始加载 SpriteFrames: ", path, " | 包含子目录: ", include_subfolders)

	# 递归查找所有 SpriteFrames
	_find_sprite_frames_in_dir(path, include_subfolders)

	print("找到 ", sprite_frames_list.size(), " 个 SpriteFrames 资源")

	if sprite_frames_list.size() > 0:
		# 按路径排序
		sprite_frames_list.sort_custom(func(a, b): return a["path"] < b["path"])

		# 默认显示第一个
		current_index = 0
		_apply_sprite_frame()

		# 更新按钮状态
		prev_button.disabled = false
		next_button.disabled = false
	else:
		print("未找到 .tres 文件")

# 递归查找目录中的 SpriteFrames 资源
func _find_sprite_frames_in_dir(path: String, include_subfolders: bool):
	var dir = DirAccess.open(path)
	if dir == null:
		print_debug("无法打开目录: ", path)
		return

	# 扫描当前目录
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		# 如果是文件且扩展名为 tres
		if not dir.current_is_dir() and file_name.get_extension() == "tres":
			var file_path = path.path_join(file_name)
			# 尝试加载资源
			var resource = _try_load_resource(file_path)
			if resource is SpriteFrames:
				sprite_frames_list.append({
					"name": file_name.get_basename(),
					"path": file_path,
					"resource": resource
				})
				print("找到 SpriteFrames: ", file_path)
			# 如果是目录且设置了包含子目录
		elif dir.current_is_dir() and file_name != "." and file_name != ".." and include_subfolders:
			var sub_dir = path.path_join(file_name)
			# 递归扫描子目录
			_find_sprite_frames_in_dir(sub_dir, include_subfolders)

		file_name = dir.get_next()
	dir.list_dir_end()

# 安全加载资源，处理可能的错误
func _try_load_resource(path: String) -> Resource:
	# 检查文件是否有效
	if not FileAccess.file_exists(path):
		return null

	# 尝试加载资源
	var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)

	# 如果加载失败，尝试在不缓存的情况下重新加载
	if resource == null:
		resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)

	return resource

func _apply_sprite_frame():
	if current_index < 0 or current_index >= sprite_frames_list.size():
		return

	# 更新索引标签
	index_label.text = "%d/%d" % [current_index + 1, sprite_frames_list.size()]

	# 更新文件夹标签显示当前文件路径
	var base_dir = folder_label.text
	var file_path = sprite_frames_list[current_index]["path"]
	if file_path.begins_with(base_dir):
		folder_label.text = file_path
	else:
		folder_label.text = file_path

	# 设置精灵资源
	sprite.sprite_frames = sprite_frames_list[current_index]["resource"]

	# 重置动画列表
	anim_list.clear()

	if sprite.sprite_frames:
		# 填充动画列表
		var animations = sprite.sprite_frames.get_animation_names()
		if animations.size() > 0:
			for i in range(animations.size()):
				anim_list.add_item(animations[i], i)
			anim_list.select(0)
			_on_animation_selected(0)
	else:
		# 如果没有动画，清空列表
		anim_list.clear()
		anim_list.add_item("资源加载失败", 0)

func _prev_sprite_frame():
	if sprite_frames_list.size() == 0:
		return

	current_index = wrapi(current_index - 1, 0, sprite_frames_list.size())
	_apply_sprite_frame()

func _next_sprite_frame():
	if sprite_frames_list.size() == 0:
		return

	current_index = wrapi(current_index + 1, 0, sprite_frames_list.size())
	_apply_sprite_frame()

func _on_animation_selected(index):
	if index < 0 or index >= anim_list.item_count:
		return

	# 获取动画名称并播放
	var anim_name = anim_list.get_item_text(index)
	sprite.play(anim_name)

func _input(event):
	# 键盘导航
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:
				_prev_sprite_frame()
				get_viewport().set_input_as_handled()
			KEY_RIGHT:
				_next_sprite_frame()
				get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	print("退出树")

func show_previewer():
	popup()

func _on_close_requested() -> void:
	print("关闭预览器Window")
	hide()