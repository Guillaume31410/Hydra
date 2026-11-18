import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

// Couleurs de la maquette A2.
const BLUE = 0x378ADD;
const BLUE_LIGHT = 0x85B7EB;
const GRAY = 0x888780;

// Durée d'affichage de la goutte après un « OUI » (millisecondes).
const QUICK_SHOW_MS = 3000;

// Dessine une goutte : un cercle surmonté d'une pointe.
function drawDrop(dc as Graphics.Dc, cx as Number, cy as Number, r as Number) as Void {
    dc.fillCircle(cx, cy, r);
    dc.fillPolygon([
        [cx, cy - (r * 2.1).toNumber()],
        [cx - (r * 0.88).toNumber(), cy - (r * 0.48).toNumber()],
        [cx + (r * 0.88).toNumber(), cy - (r * 0.48).toNumber()]
    ]);
}

function vibrate(ms as Number) as Void {
    if (Attention has :vibrate) {
        Attention.vibrate([new Attention.VibeProfile(80, ms)]);
    }
}

// ---------------------------------------------------------------------------
// Écran de la goutte : nombre de verres du jour + prochain rappel.
// En mode « rapide » (après OUI), il se referme tout seul au bout de 3 s.
// ---------------------------------------------------------------------------
class MainView extends WatchUi.View {

    private var _quick as Boolean;
    private var _timer as Timer.Timer?;

    function initialize(quick as Boolean) {
        View.initialize();
        _quick = quick;
    }

    function onShow() as Void {
        if (_quick && _timer == null) {
            vibrate(150);
            _timer = new Timer.Timer();
            _timer.start(method(:onQuickDone), QUICK_SHOW_MS, false);
        }
    }

    function onQuickDone() as Void {
        System.exit();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var center = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(BLUE, Graphics.COLOR_TRANSPARENT);
        drawDrop(dc, cx, (h * 0.24).toNumber(), (w * 0.065).toNumber());

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * 0.47).toNumber(), Graphics.FONT_NUMBER_HOT, Hydra.count().toString(), center);

        dc.setColor(GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * 0.63).toNumber(), Graphics.FONT_XTINY, "verres aujourd'hui", center);

        var next;
        if (Hydra.inActiveHours()) {
            next = "prochain : " + Hydra.formatTime(Hydra.nextReminder());
        } else {
            next = "pause jusqu'à " + Hydra.readNumber("startHour", 8) + "h";
        }
        dc.setColor(BLUE_LIGHT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * 0.76).toNumber(), Graphics.FONT_XTINY, next, center);
    }
}

// Pendant les 3 s après OUI : START ne recompte pas, BACK ferme tout de suite.
class QuickDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        return true;
    }

    function onBack() as Boolean {
        System.exit();
    }
}

// Ouverture à la main : START = +1 verre, appui long DOWN (ou UP) = réglages.
class MainDelegate extends WatchUi.BehaviorDelegate {

    private var _downTimer as Timer.Timer?;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Appui long sur DOWN (0,8 s) : ouvre les réglages.
    function onKeyPressed(evt as WatchUi.KeyEvent) as Boolean {
        if (evt.getKey() == WatchUi.KEY_DOWN) {
            _downTimer = new Timer.Timer();
            _downTimer.start(method(:onLongDown), 800, false);
            return true;
        }
        return false;
    }

    function onKeyReleased(evt as WatchUi.KeyEvent) as Boolean {
        if (evt.getKey() == WatchUi.KEY_DOWN) {
            if (_downTimer != null) {
                _downTimer.stop();
                _downTimer = null;
            }
            return true;
        }
        return false;
    }

    function onLongDown() as Void {
        _downTimer = null;
        vibrate(60);
        Settings.open();
    }

    // Appui long sur UP (menu système) : ouvre aussi les réglages, au cas où.
    function onMenu() as Boolean {
        Settings.open();
        return true;
    }

    // START : noter un verre bu sans attendre le rappel.
    function onSelect() as Boolean {
        Hydra.drink();
        vibrate(80);
        WatchUi.requestUpdate();
        return true;
    }
}
