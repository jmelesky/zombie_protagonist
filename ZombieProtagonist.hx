import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.Event;
import KeyboardMonitor;
import Actor;
import Screens;


class ZombieProtagonist {
    private var mc : MovieClip;
    private var km : KeyboardMonitor;

    private var pauseTicker : Int;
    private var blinkTicker : Int;


    private var startMessages : List<TextField>;
    private var startPics : List<DisplayObject>;
    private var levelMessage : TextField;
    private var failedMessage : TextField;
    private var deadMessage : TextField;
    private var loseMessage : TextField;

    private var levelLabel : TextField;
    private var levelDisplay : NumDisplay;
    private var currentLevel : Int;
    private var humansSavedLabel : TextField;
    private var humansSavedDisplay : NumDisplay;
    private var currentHumansSaved : Int;
    private var scoreLabel : TextField;
    private var scoreDisplay : NumDisplay;
    private var currentScore : Int;


    private var haven : Haven;


    private var hero : Hero;
    private var humans : List<Human>;
    private var zombies : List<Zombie>;

    private var havenBreached : Bool;
    private var atFault : Actor;


    public function new() {
        mc = new flash.display.MovieClip();
        flash.Lib.current.addChild(mc);
        Actor.setContainer(mc);
        Actor.setGame(this);

        km = new KeyboardMonitor();
        km.init(flash.Lib.current.stage);


        currentLevel = 1;
        currentScore = 0;

        mc.graphics.beginFill(0x116622);
        mc.graphics.drawRect(5, 405, 590, 90);
        mc.graphics.endFill();

        levelLabel = new GameLabel("level");
        levelLabel.x = 10;
        levelLabel.y = 410;
        levelLabel.width = 80;
        mc.addChild(levelLabel);

        levelDisplay = new NumDisplay(2);
        levelDisplay.x = 10;
        levelDisplay.y = 425;
        mc.addChild(levelDisplay);

        humansSavedLabel = new GameLabel("humans saved");
        humansSavedLabel.x = 210;
        humansSavedLabel.y = 410;
        humansSavedLabel.width = 120;
        mc.addChild(humansSavedLabel);

        humansSavedDisplay = new NumDisplay(3);
        humansSavedDisplay.x = 210;
        humansSavedDisplay.y = 425;
        mc.addChild(humansSavedDisplay);

        scoreLabel = new GameLabel("score");
        scoreLabel.x = 510;
        scoreLabel.y = 410;
        scoreLabel.width = 80;
        mc.addChild(scoreLabel);

        scoreDisplay = new NumDisplay(5);
        scoreDisplay.x = 390;
        scoreDisplay.y = 425;
        mc.addChild(scoreDisplay);

        deadMessage = new DeadMessage();
        mc.addChild(deadMessage);

        failedMessage = new FailedMessage();
        mc.addChild(failedMessage);

        levelMessage = new LevelMessage();
        mc.addChild(levelMessage);


        showStartMessage();
        mc.addEventListener(Event.ENTER_FRAME, startLoop);
        mc.play();
    }


    public function showStartMessage() {
        startPics = new List();
        var heropic = mc.addChild(new HeroPic());
        heropic.x = 30;
        heropic.y = 110;
        heropic.visible = true;
        startPics.add(heropic);
        var zombiepic = mc.addChild(new ZombiePic());
        zombiepic.x = 33;
        zombiepic.y = 175;
        zombiepic.visible = true;
        startPics.add(zombiepic);
        var humanpic = mc.addChild(new HumanPic());
        humanpic.x = 33;
        humanpic.y = 230;
        humanpic.visible = true;
        startPics.add(humanpic);
        var havenpic = mc.addChild(new HavenPic());
        havenpic.width = 20;
        havenpic.height = 20;
        havenpic.x = 30;
        havenpic.y = 285;
        havenpic.visible = true;
        startPics.add(havenpic);

        startMessages = new List();
        startMessages.add(new StartTitle());
        startMessages.add(new StartIntro1());
        startMessages.add(new StartHero());
        startMessages.add(new StartZombie());
        startMessages.add(new StartHuman());
        startMessages.add(new StartHaven());
        startMessages.add(new StartIntro2());
        for (message in startMessages) {
            mc.addChild(message);
            message.visible = true;
        }
    }


    public function hideStartMessage() {
        for (pic in startPics) {
            pic.visible = false;
            mc.removeChild(pic);
        }
        for (field in startMessages) {
            field.visible = false;
            mc.removeChild(field);
        }
    }


    public function initializeLevel() {
        haven = new Haven(102 - (currentLevel * 2));
        hero = new Hero(km, haven.x, haven.y);
        humans = new List();
        zombies = new List();

        FollowFlee.setHaven(haven);
        FollowFlee.setFollowKey(hero);

        currentHumansSaved = 0;
        havenBreached = false;

        var num_actors = 9;
        for (i in 1...(currentLevel+1)) {
            num_actors += i;
        }
        var num_zombies = Math.ceil(num_actors * (0.15 + (currentLevel / 100)));
        var num_humans = num_actors - num_zombies;

        for (x in 0...num_humans) {
            var human = new Human();
            this.humans.add(human);
        }


        for (x in 0...num_zombies) {
            var zombie = new Zombie(-1,-1);
            this.zombies.add(zombie);
        }

        km.clear();
        levelDisplay.update(currentLevel);
        humansSavedDisplay.update(currentHumansSaved);
    }


    public function clearLevel() {
        for (human in humans) {
            human.delete();
        }
        humans.clear();
        for (zombie in zombies) {
            zombie.delete();
        }
        zombies.clear();
        hero.delete();
        haven.delete();
    }


    public function endLevel() {
        pauseTicker = 0;
        blinkTicker = 0;
        mc.removeEventListener(Event.ENTER_FRAME, mainLoop);
        mc.addEventListener(Event.ENTER_FRAME, pauseNextLevelLoop);
    }

    public function endGame() {
        pauseTicker = 0;
        blinkTicker = 0;
        mc.removeEventListener(Event.ENTER_FRAME, mainLoop);
        mc.addEventListener(Event.ENTER_FRAME, pauseDeadLoop);
    }

    public function startLoop(event) {
        if (km.isDown(32)) {
            mc.removeEventListener(Event.ENTER_FRAME, startLoop);
            hideStartMessage();
            initializeLevel();
            mc.addEventListener(Event.ENTER_FRAME, mainLoop);
        }
    }


    public function pauseDeadLoop(event) {
        pauseTicker++; blinkTicker++;
        if (blinkTicker > 3) {
            atFault.blink();
            blinkTicker = 0;
        }
        if (pauseTicker > 30) {
            clearLevel();
            loseMessage.visible = true;
            mc.removeEventListener(Event.ENTER_FRAME, pauseDeadLoop);
            mc.addEventListener(Event.ENTER_FRAME, deadLoop);
        }
    }

    public function deadLoop(event) {
        if (km.isDown(32)) {
            mc.removeEventListener(Event.ENTER_FRAME, deadLoop);
            loseMessage.visible = false;
            currentLevel = 1;
            currentScore = 0;
            initializeLevel();
            mc.addEventListener(Event.ENTER_FRAME, mainLoop);
        }
    }

    public function pauseNextLevelLoop(event) {
        pauseTicker++; blinkTicker++;
        if (blinkTicker > 3) {
            hero.blink();
            blinkTicker = 0;
        }
        if (pauseTicker > 30) {
            currentScore += currentHumansSaved * currentLevel;
            scoreDisplay.update(currentScore);
            clearLevel();
            levelMessage.visible = true;
            mc.removeEventListener(Event.ENTER_FRAME, pauseNextLevelLoop);
            mc.addEventListener(Event.ENTER_FRAME, nextLevelLoop);
        }
    }

    public function nextLevelLoop(event) {
        if (km.isDown(32)) {
            mc.removeEventListener(Event.ENTER_FRAME, nextLevelLoop);
            levelMessage.visible = false;
            currentLevel++;
            initializeLevel();
            mc.addEventListener(Event.ENTER_FRAME, mainLoop);
        }
    }

    public function zombify_human(human, zombie) {
        humans.remove(human);
        zombies.add(zombie);
        currentScore -= currentLevel;
        if (currentScore < 0) { currentScore = 0; }
    }


    public function saveHuman(human : Human) {
        human.delete();
        humans.remove(human);
        currentScore += currentLevel;
        currentHumansSaved += 1;
    }


    public function infectedEntry(badGuy) {
        currentScore -= currentHumansSaved * currentLevel;
        atFault = badGuy;
        havenBreached = true;
    }


    public function mainLoop(event) {
        // movement
        hero.handleInput(humans, zombies);
        for (human in this.humans) {
            human.decide_and_move();
        }

        for (zombie in this.zombies) {
            zombie.decide_and_move(hero, humans);
        }

        // check for end conditions
        if (hero.hasDied()) {
            loseMessage = deadMessage;
            endGame();
        } else {
            if (havenBreached) {
                loseMessage = failedMessage;
                endGame();
            } else {
                if (humans.isEmpty()) {
                    if (currentHumansSaved > 0) {
                        endLevel();
                    } else {
                        loseMessage = failedMessage;
                        endGame();
                    }
                }
            }
        }

        // update displays
        scoreDisplay.update(currentScore);
        humansSavedDisplay.update(currentHumansSaved);
    }

    public static function main() {
        new ZombieProtagonist();
    }
}
