extends GridContainer
@onready var lcol = $LeftCol
@onready var rcol = $RightCol
@onready var ccol = $Center

func _ready():
	self.add_child(lcol)
	
