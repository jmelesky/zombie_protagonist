import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class GameFont extends flash.text.Font {}

class GameFormat extends TextFormat {
    public function new() {
        super();
        font = "GameFont";
        color = 0xffffcc;
    }
}

class StartMessage extends TextField {
    public function new() {
        super();
        embedFonts = true;
        wordWrap = true;
        var format = new GameFormat();
        format.size = 12;
        setTextFormat(format);
    }
}

class StartTitle extends TextField {
    public function new() {
        super();
        x = 30;
        y = 20;
        width = 500;
        height = 40;
        embedFonts = true;
        var titleFormat = new GameFormat();
        titleFormat.size = 36;
        titleFormat.bold = true;
        text = "Zombie Protagonist";
        setTextFormat(titleFormat);
    }
}

class StartIntro1 extends StartMessage {
    public function new() {
        super();
        x = 30;
        y = 80;
        width = 540;
        height = 15;
        text = "Zombies are taking over the world. And they're invulnerable. Sucks to be you.";
    }
}

class StartHero extends StartMessage {
    public function new() {
        super();
        x = 60;
        y = 105;
        width = 480;
        height = 45;
        text = "This is you. You're smarter than most, and will be able to fend off one or two zombies at a time without infection. Use the arrow keys to move. Hit the spacebar to yell.";
    }
}


class StartZombie extends StartMessage {
    public function new() {
        super();
        x = 60;
        y = 170;
        width = 480;
        height = 45;
        text = "This is your standard garden-variety zombie. You can't kill them. Still, they're slow and stupid, and will follow the nearest human they see. Or, if you yell at them, they'll follow you instead.";
    }
}


class StartHuman extends StartMessage {
    public function new() {
        super();
        x = 60;
        y = 225;
        width = 480;
        height = 45;
        text = "And this is an innocent human. They're also pretty stupid, and will flee nearby zombies, or run around in a random panic. Or, if you yell at them, they'll follow you. If they get touched by a zombie, they'll get infected, and will turn into a zombie.";
    }
}


class StartHaven extends StartMessage {
    public function new() {
        super();
        x = 60;
        y = 280;
        width = 480;
        height = 45;
        text = "This is the safe haven. Get people in, keep zombies (and infected people) out. Nobody can get in unless you're already inside, so have people follow you in, and duck out before the zombies can enter.";
    }
}


class StartIntro2 extends StartMessage {
    public function new() {
        super();
        x = 30;
        y = 340;
        width = 540;
        height = 60;
        text = "Right. That's it. Arrow keys to move. Spacebar to yell.\n\nAnd don't die.";
        var format = new GameFormat();
        format.size = 16;
        setTextFormat(format);
    }
}





class LevelMessage extends TextField {
    public function new() {
        super();
        x = 100;
        y = 80;
        width = 400;
        height = 300;
        embedFonts = true;
        wordWrap = true;
        visible = false;
        var format = new GameFormat();
        var titleFormat = new GameFormat();
        format.size = 12;
        titleFormat.size = 36;
        titleFormat.bold = true;
        text = "Congratulations";
        text += "\n\n";
        text += "You've managed to keep yourself and some people alive for a little longer. Enjoy a brief rest, and get ready for the next level.\n\n\n";
        text += "Hit the space bar when you're ready.";
        setTextFormat(format);
        setTextFormat(titleFormat, 0, 15);
    }
}


class DeadMessage extends TextField {
    public function new() {
        super();
        x = 50;
        y = 200;
        width = 500;
        height = 200;
        visible = false;
        text = "Game Over! You died!";
        embedFonts = true;
        var format = new GameFormat();
        format.bold = true;
        format.size = 48;
        setTextFormat(format);
    }
}


class FailedMessage extends TextField {
    public function new() {
        super();
        x = 25;
        y = 200;
        width = 550;
        height = 200;
        visible = false;
        text = "Game Over! All the humans died!";
        embedFonts = true;
        var format = new GameFormat();
        format.bold = true;
        format.size = 36;
        setTextFormat(format);
    }
}


class GameLabel extends TextField {
    public function new(labelString) {
        super();
        height = 15;
        embedFonts = true;
        text = labelString;
        var format = new GameFormat();
        format.size = 12;
        format.align = TextFormatAlign.CENTER;
        setTextFormat(format);
    }
}


class NumDisplay extends TextField {
    private var digits : Int;

    public function new(digits) {
        this.digits = digits;
        super();
        height = 60;
        width = digits * 40;
        embedFonts = true;
        for (i in 0...digits) {
            text += "0";
        }
        var format = new GameFormat();
        format.size = 58;
        format.align = TextFormatAlign.CENTER;
        setTextFormat(format);
        defaultTextFormat = format;
    }

    public function update(number : Int) {
        var newtext = number + "";
        var counter = 10;
        for (i in 1...digits) {
            if (number < counter) {
                newtext = "0" + newtext;
            }
            counter = counter * 10;
        }
        text = newtext;
    }
}

