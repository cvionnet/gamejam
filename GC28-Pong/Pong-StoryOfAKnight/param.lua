

-- MAIN
DEBUG_MODE = true

PLAYER_LIFE = 10
VILLAGE_LIFE = 100
MONSTER_LIFE = 2 --50
MONSTER_PERCENT_APPEAR_2ND_MONSTER = 50 --20
BULLET_TIME_SPEED = 15


-- MAP
SPRITE_MAP_RATIO = 2
FRAME_PER_SECOND_MAP = 4


-- COMMON
FRAME_PER_SECOND = 24
SPRITE_RATIO = 2

fontBig = love.graphics.newFont("fonts/Gameplay.ttf", 70)


-- PLAYER
GRAVITY = .9
STOP_PLAYER = .5  --.01
PLAYER_FEET_HEIGHT = 6


-- MONSTER
TIME_WARNING = 1  --4
TIME_HURT_PLAYER = 0.3
TIME_MIN_CREATE_TENTACLE = 1 --10
TIME_MAX_CREATE_TENTACLE = 1 --20
MAX_TENTACLE = 1 --10
TIME_DISPLAY_MESSAGE_VILLAGE = 5
SIDE_POSITIONS = {"up", "right", "down", "left"}     -- 4th positions on the screen


-- TENTACLE
FRAME_PER_SECOND_TENTACLE = 4
TIME_MIN_SHOOT_BULLET = 0.5
TIME_MAX_SHOOT_BULLET = 1
TENTACLE_MIN_LIFE = 2
TENTACLE_MAX_LIFE = 5
