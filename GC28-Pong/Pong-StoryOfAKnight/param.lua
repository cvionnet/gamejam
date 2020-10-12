
-- MAIN
DEBUG_MODE = false
DEBUG_PASS_MENU = false

PLAYER_LIFE = 10
VILLAGE_LIFE = 100
MONSTER_LIFE = 2 --50
MONSTER_PERCENT_APPEAR_2ND_MONSTER = 50 --20
BULLET_TIME_SLOW_FACTOR = 0.5
BULLET_TIME_LENGTH = 25
BULLET_TIME_LOSS_SPEED = 3
BULLET_TIME_SPEED = 15

--------------------------------------------------------------------------------------------------------

-- COMMON
LANGUAGE = "FR"     -- FR / EN
FRAME_PER_SECOND = 24
X_SCREENSIZE = 0
Y_SCREENSIZE = 0

TITLE = "PONG, the Knight"
SUB_TITLE = "Story of a fight"

fontTitle = love.graphics.newFont("fonts/jabjai_heavy.ttf", 85)
fontSubTitle = love.graphics.newFont("fonts/jabjai_heavy.ttf", 25)
fontMenu = love.graphics.newFont("fonts/jabjai_heavy.ttf", 35)
fontEndgame = love.graphics.newFont("fonts/Computerfont.ttf", 60)
fontDialog = love.graphics.newFont("fonts/Computerfont.ttf", 30)
fontWarning = love.graphics.newFont("fonts/Paintling.ttf", 50)

--------------------------------------------------------------------------------------------------------

-- UI
TEXT_SPEED = 0.1

imgParchment = love.graphics.newImage("images/ui/parchment.png")
imgBulletTime = love.graphics.newImage("images/ui/bullettime.png")
imgButtonNext = love.graphics.newImage("images/ui/next_button.png")
imgHowToPlay = love.graphics.newImage("images/ui/howtoplay.png")

imgFlagFR = love.graphics.newImage("images/ui/flagFR.png")
imgFlagEN = love.graphics.newImage("images/ui/flagEN.png")

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
sndBraaamInverse = love.audio.newSource("sounds/fx/braaam_inverse.wav", "static")
sndBulletTime = love.audio.newSource("sounds/fx/bullettime.wav", "static")

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
musicIntro = love.audio.newSource("sounds/music/intro.ogg", "stream")
musicMenu = love.audio.newSource("sounds/music/menu.ogg", "stream")
musicVictory = love.audio.newSource("sounds/music/victory.ogg", "stream")
musicGameover = love.audio.newSource("sounds/music/gameover.ogg", "stream")

--------------------------------------------------------------------------------------------------------

-- MENU
FRAME_PER_SECOND_HEAD = 4

menu1_FR = "Demarrer"
menu2_FR = "Comment jouer"
menu3_FR = "Quitter"

menu1_EN = "New game"
menu2_EN = "How to play"
menu3_EN = "Quit game"

--------------------------------------------------------------------------------------------------------

-- INTRODUCTION
imgPlayer = love.graphics.newImage("images/ui/question_mark.png")
imgQuestionMark = love.graphics.newImage("images/ui/question_mark.png")

lstIntroductionText_FR = {}
lstIntroductionText_FR[1] = "Ca y est ! Le village est en place tout autour de ce carrefour"
lstIntroductionText_FR[2] = "Tout ce travail n'etait pas inutile, je vais enfin pouvoir me reposer un peu"
lstIntroductionText_FR[3] = "Chevalier Pong ?"      -- enemy
lstIntroductionText_FR[4] = ". . ."
lstIntroductionText_FR[5] = ". . ."
lstIntroductionText_FR[6] = "( ca sent l'embrouille ... )"
lstIntroductionText_FR[7] = ". . ."
lstIntroductionText_FR[8] = "mmmm, c'est pour quoi ?"
lstIntroductionText_FR[9] = "Nous sommes l'Ordre du Ping"   -- enemy
lstIntroductionText_FR[10] = "( l'ordre du Ping ... serieusement ?!? )"
lstIntroductionText_FR[11] = "et nous devons detruire ce village !"     -- enemy
lstIntroductionText_FR[12] = "En garde !"     -- enemy

lstIntroductionText_EN = {}
lstIntroductionText_EN[1] = "That's it! The village is in place all around this crossroads"
lstIntroductionText_EN[2] = "All this work was not useless, I will finally be able to rest for a while"
lstIntroductionText_EN[3] = "Are you Pong, the Knight ?"      -- enemy
lstIntroductionText_EN[4] = ". . ."
lstIntroductionText_EN[5] = ". . ."
lstIntroductionText_EN[6] = "( it smells like trouble ... )"
lstIntroductionText_EN[7] = ". . ."
lstIntroductionText_EN[8] = "mmmm, what do you want ?"
lstIntroductionText_EN[9] = "We are the Order of the Ping"   -- enemy
lstIntroductionText_EN[10] = "( the order of the Ping ... seriously ?!? )"
lstIntroductionText_EN[11] = "and we come to destroy this village !"     -- enemy
lstIntroductionText_EN[12] = "Prepare to fight !"     -- enemy

--------------------------------------------------------------------------------------------------------

-- VICTORY
imgVictory_Head = love.graphics.newImage("images/player/head/hero_head1.png")
victoryText_FR = "VICTOIRE !"
lstVictoryText_FR = {}
lstVictoryText_FR[1] = "Tu as vaincu tous tes enemis. Grace a tes actions, le village va pouvoir vivre de nouveau en paix."
lstVictoryText_FR[2] = ". . ."
lstVictoryText_FR[3] = "A moins que ..."


victoryText_EN = "VICTORY !"
lstVictoryText_EN = {}
lstVictoryText_EN[1] = "You have defeated all your enemies. Thanks to your actions, the village will be able to live in peace again."
lstVictoryText_EN[2] = ". . ."
lstVictoryText_EN[3] = "Unless ..."

--------------------------------------------------------------------------------------------------------

-- GAME OVER
imgGameover_Head = love.graphics.newImage("images/player/head/hero_head_gameover.png")
gameoverText_FR = "GAME OVER !"
lstGameoverText_FR = {}
lstGameoverText_FR[1] = "Tu as ete defait par tes enemis. Le village a ete detruit et tous les villageois emmenes comme esclaves."
lstGameoverText_FR[2] = ". . ."
lstGameoverText_FR[3] = "Ta seule chance reste d'utiliser cette pierre de resurrection ..."

gameoverText_EN = "GAME OVER !"
lstGameoverText_EN = {}
lstGameoverText_EN[1] = "You have been defeated by your enemies. The village has been destroyed, and villagers taken as slaves."
lstGameoverText_EN[2] = "..."
lstGameoverText_EN[3] = "Your only chance is to use this resurrection stone ..."

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
PLAYER_SPEED = 60
FRAME_PER_SECOND_PLAYER_IDLE = 4
FRAME_PER_SECOND_PLAYER_RUN = 12
PARTICLE_GRAVITY = .9
STOP_PLAYER = .5  --.01
PLAYER_FEET_HEIGHT = 6

--------------------------------------------------------------------------------------------------------

-- MONSTER
MONSTER_WALKING_SPEED = 250
SPRITE_MONSTER_RATIO = 1
TIME_WARNING = 3  -- 1
TIME_MIN_CREATE_ENEMY = 2 --0.1
TIME_MAX_CREATE_ENEMY = 10 --0.1
MAX_ENEMY = 10 --1
TIME_DISPLAY_MESSAGE_VILLAGE = 2
SIDE_POSITIONS = {"up", "right", "down", "left"}     -- the 4 positions on the screen

--------------------------------------------------------------------------------------------------------

-- ENEMY
SPRITE_ENEMY_RATIO = 4
FRAME_PER_SECOND_ENEMY = 2
FRAME_PER_SECOND_ENEMY_ATTACK = 20
ENEMY_WALKING_SPEED = 50
TIME_HURT_PLAYER = 1 --0.3
TIME_MIN_SHOOT_BULLET = 1 --0.5
TIME_MAX_SHOOT_BULLET = 3 --1
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
