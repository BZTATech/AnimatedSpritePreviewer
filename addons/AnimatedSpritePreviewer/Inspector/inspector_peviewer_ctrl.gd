@tool
extends VBoxContainer
class_name InspectorPeviewerCtrl
# UI 元素
@export
@onready var sprite: AnimatedSprite2D
@export
@onready var anim_list: OptionButton
@export
@onready var animation_name_label: Label
@export
@onready var lastBtn: Button
@export
@onready var playBtn: Button
@export
@onready var nextBtn: Button

var playing: bool = true

# 当前资源
var current_resource: SpriteFrames = null

func _ready():
	# 窗口设置
	# 连接信号
	anim_list.item_selected.connect(_on_animation_selected)
	lastBtn.pressed.connect(_lastPressed)
	nextBtn.pressed.connect(_nextPressed)
	playBtn.pressed.connect(_playPressed)
		
	print("InspectorPreviewer _ready")
	_update_animation_list()
	# 初始状态
	print(current_resource)
	animation_name_label.hide()


func _update_animation_list():
	anim_list.clear()

	if current_resource:
		var animations = current_resource.get_animation_names()
		if animations.size() > 0:
			for i in range(animations.size()):
				anim_list.add_item(animations[i], i)
			anim_list.select(0)
			_on_animation_selected(0)
			_setPlayBtnState(true)
		else:
			anim_list.add_item("No Animations", 0)
			anim_list.disabled = true
			_setPlayBtnState(false)

func _on_animation_selected(index):
	sprite.sprite_frames = current_resource
	if current_resource and index < anim_list.item_count:
		var anim_name = anim_list.get_item_text(index)
		sprite.play(anim_name)

func _setPlayBtnState(enabled: bool):
	if enabled:
		lastBtn.show()
		nextBtn.show()
	else:
		lastBtn.hide()
		nextBtn.hide()
	
func _playPressed():
	if(anim_list.disabled):
		return
	playing=not playing
	
	if playing:
		playBtn.text="Pause"
		sprite.play()
	else:
		playBtn.text="Play"
		sprite.stop()
		

func _lastPressed():
	if(anim_list.disabled):
		return 
		
	if anim_list.selected > 0:
		anim_list.selected -= 1
	else:
		anim_list.selected = anim_list.item_count - 1
	_on_animation_selected(anim_list.selected)
	
func _nextPressed():
	if(anim_list.disabled):
		return 
		
	if anim_list.selected < anim_list.item_count - 1:
		anim_list.selected += 1
	else:
		anim_list.selected = 0
	_on_animation_selected(anim_list.selected)

 

func _input(event):
	# 空格键播放/暂停
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		_playPressed()
