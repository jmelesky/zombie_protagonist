import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import ZombieProtagonist;

class HeroPic extends Sprite {}
class HumanPic extends Sprite {}
class ZombiePic extends Sprite {}
class HavenPic extends Sprite {}

class Actor {
    static var _actorcounter = 0;
    static var container : MovieClip;
    static var game : ZombieProtagonist;

    public var x : Int;
    public var y : Int;
    public var pic : DisplayObject;
    private var direction_x : Int;
    private var direction_y : Int;
    public var size : Int;
    private var speed : Int;
    private var persistence : Float;

    static public function setContainer(new_container) {
        container = new_container;
    }

    static public function setGame(new_game) {
        game = new_game;
    }

    public function new(img, startx, starty, size, speed, persistence) {
        pic = container.addChild(img);
        pic.visible = true;
        _actorcounter++;
        x = startx;
        y = starty;
        pic.x = startx - Math.floor(size / 2);
        pic.y = starty - Math.floor(size / 2);
        direction_x = 0;
        direction_y = 0;
        this.size = size;
        this.speed = speed;
        this.persistence = persistence;
    }

    public function move(x,y) {
        var old_x = this.pic.x;
        var old_y = this.pic.y;
        this.pic.x += x * this.speed;
        this.pic.y += y * this.speed;
        this.x += x * this.speed;
        this.y += y * this.speed;

        if ((this.x > 590) || (this.x < 10)) {
            pic.x = old_x;
            this.x = Math.ceil(old_x + (size / 2));
        }
        if ((this.y > 390) || (this.y < 10)) {
            pic.y = old_y;
            this.y = Math.ceil(old_y + (size / 2));
        }
    }

    public function moveTo(new_x, new_y) {
        x = new_x;
        y = new_y;
        pic.x = new_x - Math.floor(size / 2);
        pic.y = new_y - Math.floor(size / 2);
        direction_x = 0;
        direction_y = 0;
    }

    public function moveInDirection() {
        move(direction_x, direction_y);
    }


    public function moveRandom() {
        if (Math.random() > persistence) {
            if (Math.random() > .5) {
                direction_x = Math.round(Math.min(1, (direction_x + 1)));
            } else {
                direction_x = Math.round(Math.max(-1, (direction_x - 1)));
            }
        }
        if (Math.random() > persistence) {
            if (Math.random() > .5) {
                direction_y = Math.round(Math.min(1, (direction_y + 1)));
            } else {
                direction_y = Math.round(Math.max(-1, (direction_y - 1)));
            }
        }
        this.moveInDirection();
    }


    public function directionTowards(following) {
        if (following.x < x) {
            direction_x = -1;
        } else {
            if (following.x > x) {
                direction_x = 1;
            } else {
                direction_x = 0;
            }
        }

        if (following.y < y) {
            direction_y = -1;
        } else {
            if (following.y > y) {
                direction_y = 1;
            } else {
                direction_y = 0;
            }
        }
    }


    public function directionFrom(from) {
        if (from.x < x) {
            direction_x = 1;
        } else {
            if (from.x > x) {
                direction_x = -1;
            } else {
                direction_x = 0;
            }
        }

        if (from.y < y) {
            direction_y = 1;
        } else {
            if (from.y > y) {
                direction_y = -1;
            } else {
                direction_y = 0;
            }
        }
    }


    public function distanceTo(that) {
        return Math.round(Math.abs(this.x - that.x) +
                          Math.abs(this.y - that.y));
    }


    public function overlaps(that : Actor) {
        if ((Math.abs(this.x - that.x) < this.size) &&
            (Math.abs(this.y - that.y) < this.size)) {
            return true;
        } else {
            return false;
        }
    }


    public function delete() {
        container.removeChild(this.pic);
    }


    public function coords() {
        return pic.x + "x" + pic.y;
    }

    public function hitTest(x) {
        return this.pic.hitTestObject(x);
    }


    public function blink() {
        pic.visible = ! pic.visible;
    }
}


class FollowFlee extends Actor {
    static var currentHaven : Haven;
    static var followKey : Hero;
    private var current_fears : List<Actor>;
    private var following : Actor;

    static public function setHaven(newHaven : Haven) {
        currentHaven = newHaven;
    }

    static public function setFollowKey(newFollowKey : Hero) {
        followKey = newFollowKey;
    }


    public function new(img, startx, starty, size, speed, persistence) {
        current_fears = new List<Actor>();
        following = null;
        super(img, startx, starty, size, speed, persistence);
    }

    public override function move(x,y) {
        var old_x = this.x;
        var old_y = this.y;
        super.move(x,y);

        var box = currentHaven;
        var leftbound = box.x - (box.size / 2);
        var rightbound = leftbound + box.size;
        var upbound = box.y - (box.size / 2);
        var downbound = upbound + box.size;

        if (((this.x + (size / 2)) >= leftbound) &&
            ((this.x - (size / 2)) <= rightbound) &&
            ((this.y + (size / 2)) >= upbound) &&
            ((this.y - (size / 2)) <= downbound)) {
            if (((followKey.x + (size / 2)) >= leftbound) &&
                ((followKey.x - (size / 2)) <= rightbound) &&
                ((followKey.y + (size / 2)) >= upbound) &&
                ((followKey.y - (size / 2)) <= downbound)) {
                touchedHaven();
            } else {
                this.x = old_x;
                this.y = old_y;
                pic.x = old_x - Math.floor(size / 2);
                pic.y = old_y - Math.floor(size / 2);
            }
        }
    }

    public function shouldFollow(actor) {
        following = actor;
    }

    public function shouldFear(zombie) {
        current_fears.add(zombie);
    }

    public function touchedHaven() {}
}


class Human extends FollowFlee {
    private var infected_for : Int;

    public function new() {
        infected_for = 0;
        var img = new HumanPic();

        var startx;
        var starty;
        var box = FollowFlee.currentHaven;
        var leftbound = box.x - (box.size / 2);
        var rightbound = leftbound + box.size;
        var upbound = box.y - (box.size / 2);
        var downbound = upbound + box.size;

        var useit = false;
        while (!useit) {
            useit = true;
            startx = Math.round((Math.random() * 540) + 30);
            starty = Math.round((Math.random() * 340) + 30);
            if ((((startx + 8) >= leftbound) && ((startx - 8) <= rightbound))
                &&
                (((starty + 8) >= upbound) && ((starty - 8) <= downbound))) {
                useit = false;
            }
        }
        super(img, startx, starty, 15, 2, .8);
    }


    public function infect() {
        infected_for++;
    }

    public function zombify() {
        var startx = x;
        var starty = y;
        delete();
        Actor.game.zombify_human(this, new Zombie(startx, starty));
    }


    public function decide_and_move() {
        if (infected_for > 0) {
            infected_for++;
        }
        if (infected_for > 60) {
            zombify();
        } else {
            if (following != null) {
                directionTowards(following);
                moveInDirection();
                if ((current_fears.length > 5) ||
                    (distanceTo(following) > 120)) {
                    following = null;
                }
                current_fears.clear();
            } else {
                if (current_fears.length > 0) {
                    var fleeing = null;
                    var fleeing_dist = 80;
                    for (fear in current_fears) {
                        if (distanceTo(fear) < fleeing_dist) {
                            fleeing = fear;
                            fleeing_dist = distanceTo(fear);
                        }
                    }
                    directionFrom(fleeing);
                    moveInDirection();
                    current_fears.clear();
                } else {
                    moveRandom();
                }
            }
        }
    }


    public override function touchedHaven() {
        if (infected_for > 0) {
            Actor.game.infectedEntry(this);
        } else {
            Actor.game.saveHuman(this);
        }
    }

}

class Zombie extends FollowFlee {
    public function new(givenx, giveny) {
        var img = new ZombiePic();

        if (givenx == -1) {
            var startx;
            var starty;
            if (Math.random() > .5) {
                if (Math.random() > .5) {
                    // top
                    startx = Math.round((Math.random() * 580) + 10);
                    starty = 10;
                } else {
                    // bottom
                    startx = Math.round((Math.random() * 580) + 10);
                    starty = 390;
                }
            } else {
                if (Math.random() > .5) {
                    // left
                    startx = 10;
                    starty = Math.round((Math.random() * 380) + 10);
                } else {
                    // right
                    startx = 590;
                    starty = Math.round((Math.random() * 380) + 10);
                }
            }
            super(img, startx, starty, 15, 1, .6);
        } else {
            super(img, givenx, giveny, 15, 1, .6);
        }
    }


    // overridden to incorporate patented "lurch" effect
    public override function moveInDirection() {
        super.moveInDirection();
        var lurch_rand = Math.random();
        if (lurch_rand > .5) {
            if (lurch_rand > .7) {
                var move_x = 0;
                var move_y = 0;
                if (lurch_rand > .85) {
                    if (Math.random() > .5) {
                        move_x = 1;
                    } else {
                        move_y = 1;
                    }
                } else {
                    if (Math.random() > .5) {
                        move_x = -1;
                    } else {
                        move_y = -1;
                    }
                }
                move(move_x, move_y);
            } else {
                direction_x = -direction_x;
                direction_y = -direction_y;
                super.moveInDirection();
                direction_x = -direction_x;
                direction_y = -direction_y;
            }
        }
    }



    public function decide_and_move(hero : Hero, humans : List<Human>) {
        if (following != null) {
            directionTowards(following);
            moveInDirection();
        } else {
            moveRandom();
        }

        var nearest : Actor = null;
        var nearest_dist = 120;
        for (human in humans) {
            var dist = distanceTo(human);
            if (dist < 120) {
                if (overlaps(human)) {
                    human.infect();
                } else {
                    if (dist < 80) {
                        human.shouldFear(this);
                    }
                    if (dist < nearest_dist) {
                        nearest = human;
                        nearest_dist = Math.round(dist);
                    }
                }
            }
        }

        var hero_dist = distanceTo(hero);
        if (hero_dist < 120) {
            if (overlaps(hero)) {
                hero.isTouched();
            } else {
                if (hero_dist < nearest_dist) {
                    nearest = hero;
                }
            }
        }

        following = nearest;
    }


    public override function touchedHaven() {
        Actor.game.infectedEntry(this);
    }

}

class Hero extends Actor {
    private var km : KeyboardMonitor;

    private var touchedBy : Int;

    public function new(km, startx, starty) {
        this.km = km;
        touchedBy = 0;
        var img = new HeroPic();
        super(img, startx, starty, 20, 3, .9);
    }



    public function moveUp() {
        move(0, -1);
    }
    public function moveDown() {
        move(0, 1);
    }
    public function moveLeft() {
        move(-1, 0);
    }
    public function moveRight() {
        move(1, 0);
    }

    public function yell(humans : List<Human>, zombies : List<Zombie>) {
        for (human in humans) {
            if (distanceTo(human) < 100) {
                human.shouldFollow(this);
            }
        }
        for (zombie in zombies) {
            if (distanceTo(zombie) < 100) {
                zombie.shouldFollow(this);
            }
        }
    }


    public function isTouched() {
        touchedBy++;
    }

    public function hasDied() {
        return (touchedBy > 2);
    }

    public function handleInput(humans : List<Human>, zombies : List<Zombie>) {
        if (km.isDown(37)) { moveLeft(); }
        if (km.isDown(39)) { moveRight(); }
        if (km.isDown(38)) { moveUp(); }
        if (km.isDown(40)) { moveDown(); }
        if (km.isDown(32)) { yell(humans, zombies); }
        touchedBy = 0;
    }
}


class Haven extends Actor {
    public function new(size : Int) {
        var img = new HavenPic();
        img.width = size;
        img.height = size;
        var startx = Math.round(Math.random() * 400) + 100;
        var starty = Math.round(Math.random() * 200) + 100;
        super(img, startx, starty, size, 0, 0);
    }
        
}


