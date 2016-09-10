import flash.ui.Keyboard;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.events.Event;

class KeyboardMonitor {
    private var keys : Array<Bool>;

    public function new() {
        keys = new Array();
        for (i in 0...256) {
            keys[i] = false;
        }
    }

    public function init(stage : Stage) {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keypress);
        stage.addEventListener(KeyboardEvent.KEY_UP, this.keyunpress);
        stage.addEventListener(Event.DEACTIVATE, clearKeys);
    }

    private function keypress(event) {
        keys[event.keyCode] = true;
    }

    private function keyunpress(event) {
        keys[event.keyCode] = false;
    }


    private function clearKeys(event) {
        for (i in 0...256) {
            keys[i] = false;
        }
    }

    public function clear() {
        for (i in 0...256) {
            keys[i] = false;
        }
    }

    public function isDown(n) {
        return keys[n];
    }
}
