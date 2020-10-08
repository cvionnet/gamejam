

-- MAIN
DEBUG_MODE = true
DEBUG_PASS_MENU = true


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
fontWarning = love.graphics.newFont("fonts/Paintling.ttf", 50)


-- EFFECTS
-- To make the screen shaking
CAM_SHAKE_TIMING = 0.2
CAM_SHAKE_OFFSET = 2

camShake = {}
camShake.shake = false      -- shake active ?
camShake.shakeTimer = 0     -- how long
camShake.shakeOffset = CAM_SHAKE_OFFSET    -- how much


-- To make a sprite blinking
shaderBlink = love.graphics.newShader[[
    extern float WhiteFactor;

    vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
    {
        vec4 outputcolor = Texel(tex, texcoord) * vcolor;
        outputcolor.rgb += vec3(WhiteFactor);
        return outputcolor;
    }
]]



-- PLAYER
SPRITE_PLAYER_RATIO = 2
FRAME_PER_SECOND_PLAYER_IDLE = 4
FRAME_PER_SECOND_PLAYER_RUN = 12
GRAVITY = .9
STOP_PLAYER = .5  --.01
PLAYER_FEET_HEIGHT = 6


-- MONSTER
MONSTER_WALKING_SPEED = 250
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
FRAME_PER_SECOND_ENEMY = 2
FRAME_PER_SECOND_ENEMY_ATTACK = 20
ENEMY_WALKING_SPEED = 50
TIME_MIN_SHOOT_BULLET = 0.5
TIME_MAX_SHOOT_BULLET = 1
ENEMY_MIN_LIFE = 2
ENEMY_MAX_LIFE = 5


-- BULLET
SPRITE_BULLET_RATIO = 1
BULLET_MIN_SPEED = 200 --200
BULLET_MAX_SPEED = 200 --300


-- EXPLOSION
FRAME_PER_SECOND_EXPLOSION = 8
