

-- MAIN
DEBUG_MODE = true

PLAYER_LIFE = 10
VILLAGE_LIFE = 100
MONSTER_LIFE = 2 --50
MONSTER_PERCENT_APPEAR_2ND_MONSTER = 50 --20
BULLET_TIME_SPEED = 15


-- MENU
FRAME_PER_SECOND_HEAD = 4


-- MAP
SPRITE_MAP_RATIO = 2
FRAME_PER_SECOND_MAP = 4


-- COMMON
FRAME_PER_SECOND = 24
X_SCREENSIZE = 0
Y_SCREENSIZE = 0

TITLE = "PONG, the Knight"
SUB_TITLE = "Story of a fight"

fontTitle = love.graphics.newFont("fonts/jabjai_heavy.ttf", 85)
fontSubTitle = love.graphics.newFont("fonts/jabjai_heavy.ttf", 25)
fontMenu = love.graphics.newFont("fonts/jabjai_heavy.ttf", 35)
fontDialog = love.graphics.newFont("fonts/Computerfont.ttf", 30)
fontBig = love.graphics.newFont("fonts/Computerfont.ttf", 50)


-- PLAYER
SPRITE_PLAYER_RATIO = 2
FRAME_PER_SECOND_PLAYER = 12
GRAVITY = .9
STOP_PLAYER = .5  --.01
PLAYER_FEET_HEIGHT = 6


-- MONSTER
SPRITE_MONSTER_RATIO = 1
TIME_WARNING = 1  --4
TIME_HURT_PLAYER = 0.3
TIME_MIN_CREATE_ENEMY = 0.1 --10
TIME_MAX_CREATE_ENEMY = 0.1 --20
MAX_ENEMY = 1 --10
TIME_DISPLAY_MESSAGE_VILLAGE = 5
SIDE_POSITIONS = {"up", "right", "down", "left"}     -- 4th positions on the screen


-- ENEMY
SPRITE_ENEMY_RATIO = 4
FRAME_PER_SECOND_ENEMY = 6
TIME_MIN_SHOOT_BULLET = 0.5
TIME_MAX_SHOOT_BULLET = 1
ENEMY_MIN_LIFE = 2
ENEMY_MAX_LIFE = 5


-- BULLET
SPRITE_BULLET_RATIO = 1
BULLET_MIN_SPEED = 200 --200
BULLET_MAX_SPEED = 200 --300
