
-- MAIN
DEBUG_MODE = true
DEBUG_PASS_MENU = true

PLAYER_LIFE = 10
VILLAGE_LIFE = 100
MONSTER_LIFE = 2 --50
MONSTER_PERCENT_APPEAR_2ND_MONSTER = 50 --20
BULLET_TIME_SLOW_FACTOR = 0.5
BULLET_TIME_LENGTH = 15
BULLET_TIME_LOSS_SPEED = 3
BULLET_TIME_SPEED = 15

--------------------------------------------------------------------------------------------------------

-- COMMON
FRAME_PER_SECOND = 24
X_SCREENSIZE = 0
Y_SCREENSIZE = 0

TITLE = "PONG, the Knight"
SUB_TITLE = "Story of a fight"

fontTitle = love.graphics.newFont("fonts/jabjai_heavy.ttf", 85)
fontSubTitle = love.graphics.newFont("fonts/jabjai_heavy.ttf", 25)
fontMenu = love.graphics.newFont("fonts/jabjai_heavy.ttf", 35)
fontEndgame = love.graphics.newFont("fonts/jabjai_heavy.ttf", 60)
fontDialog = love.graphics.newFont("fonts/Computerfont.ttf", 30)
fontWarning = love.graphics.newFont("fonts/Paintling.ttf", 50)

--------------------------------------------------------------------------------------------------------

-- UI
imgParchment = love.graphics.newImage("images/ui/parchment.png")
imgBulletTime = love.graphics.newImage("images/ui/bullettime.png")

imgVillageHealth = love.graphics.newImage("images/ui/village.png")
imgVillageFire = love.graphics.newImage("images/ui/village_fire.png")

imgPlayerHealth100 = love.graphics.newImage("images/player/health/hero_head_health1.png")
imgPlayerHealth80 = love.graphics.newImage("images/player/health/hero_head_health2.png")
imgPlayerHealth60 = love.graphics.newImage("images/player/health/hero_head_health3.png")
imgPlayerHealth40 = love.graphics.newImage("images/player/health/hero_head_health4.png")
imgPlayerHealth20 = love.graphics.newImage("images/player/health/hero_head_health5.png")

--------------------------------------------------------------------------------------------------------

-- SOUNDS - fx
sndMenuUpDown = love.audio.newSource("sounds/fx/menu_updown.wav", "static")
sndMenuSelect = love.audio.newSource("sounds/fx/menu_select.wav", "static")

sndGameBullet_EnemyHit = love.audio.newSource("sounds/fx/game_bullet_enemy_hit.wav", "static")
sndGameBullet_PlayerHit = love.audio.newSource("sounds/fx/game_bullet_player_hit.wav", "static")
sndGameBullet_VillageHit = love.audio.newSource("sounds/fx/game_bullet_village_hit.wav", "static")

sndGameEnemy_Bullet = love.audio.newSource("sounds/fx/game_enemy_bullet.wav", "static")
sndGameEnemy_Death = love.audio.newSource("sounds/fx/game_enemy_death.wav", "static")
sndGameEnemy_Appear = love.audio.newSource("sounds/fx/game_enemy_appear.wav", "static")
sndGameEnemy_Disappear = love.audio.newSource("sounds/fx/game_enemy_disappear.wav", "static")
sndGameEnemy_Walk = love.audio.newSource("sounds/fx/game_enemy_footstep_walk.wav", "static")

sndGamePlayer_Walk = love.audio.newSource("sounds/fx/game_player_footstep_run.wav", "static")


-- SOUNDS - music
musicBattle = love.audio.newSource("sounds/music/battle.ogg", "stream")

--------------------------------------------------------------------------------------------------------

-- MENU
FRAME_PER_SECOND_HEAD = 4

--------------------------------------------------------------------------------------------------------

-- VICTORY

imgVictory_Head = love.graphics.newImage("images/player/head/hero_head1.png")


--------------------------------------------------------------------------------------------------------

-- GAME OVER

imgGameover_Head = love.graphics.newImage("images/player/head/hero_head_gameover.png")


--------------------------------------------------------------------------------------------------------

-- MAP
SPRITE_MAP_RATIO = 2
FRAME_PER_SECOND_MAP = 4
FOG_SCROLLINGSPEED = 40

imgFog = love.graphics.newImage("images/map/fog.png")
imgFog2 = love.graphics.newImage("images/map/fog2.png")

--------------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------------

-- PLAYER
SPRITE_PLAYER_RATIO = 2
FRAME_PER_SECOND_PLAYER_IDLE = 4
FRAME_PER_SECOND_PLAYER_RUN = 12
GRAVITY = .9
STOP_PLAYER = .5  --.01
PLAYER_FEET_HEIGHT = 6

--------------------------------------------------------------------------------------------------------

-- MONSTER
MONSTER_WALKING_SPEED = 250
SPRITE_MONSTER_RATIO = 1
TIME_WARNING = 1  --4
TIME_HURT_PLAYER = 0.3
TIME_MIN_CREATE_ENEMY = 0.1 --10
TIME_MAX_CREATE_ENEMY = 0.1 --20
MAX_ENEMY = 1 -- 10
TIME_DISPLAY_MESSAGE_VILLAGE = 2
SIDE_POSITIONS = {"up", "right", "down", "left"}     -- the 4 positions on the screen

--------------------------------------------------------------------------------------------------------

-- ENEMY
SPRITE_ENEMY_RATIO = 4
FRAME_PER_SECOND_ENEMY = 2
FRAME_PER_SECOND_ENEMY_ATTACK = 20
ENEMY_WALKING_SPEED = 50
TIME_MIN_SHOOT_BULLET = 0.5 -- 1
TIME_MAX_SHOOT_BULLET = 1   -- 3
ENEMY_MIN_LIFE = 2
ENEMY_MAX_LIFE = 5

--------------------------------------------------------------------------------------------------------

-- BULLET
SPRITE_BULLET_RATIO = 1
BULLET_MIN_SPEED = 200
BULLET_MAX_SPEED = 300

--------------------------------------------------------------------------------------------------------

-- EXPLOSION
FRAME_PER_SECOND_EXPLOSION = 8
