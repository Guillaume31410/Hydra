import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Menu de réglages sur la montre (appui long sur DOWN depuis l'écran principal).
// Chaque ligne ouvre une liste de valeurs ; START choisit, BACK annule.
module Settings {

    const KEYS = ["intervalMin", "startHour", "endHour", "snoozeMin"];

    function title(key as String) as String {
        if (key.equals("intervalMin")) { return "Intervalle"; }
        if (key.equals("startHour")) { return "Début"; }
        if (key.equals("endHour")) { return "Fin"; }
        return "Plus tard";
    }

    function options(key as String) as Array<Number> {
        if (key.equals("intervalMin")) { return [15, 20, 30, 45, 60, 75, 90, 120]; }
        if (key.equals("startHour")) { return [5, 6, 7, 8, 9, 10, 11, 12]; }
        if (key.equals("endHour")) { return [17, 18, 19, 20, 21, 22, 23, 24]; }
        return [5, 10, 15, 20, 30];
    }

    function fallback(key as String) as Number {
        if (key.equals("intervalMin")) { return 45; }
        if (key.equals("startHour")) { return 8; }
        if (key.equals("endHour")) { return 21; }
        return 10;
    }

    function label(key as String, value as Number) as String {
        if (key.equals("startHour") || key.equals("endHour")) { return value + "h"; }
        return value + " min";
    }

    function current(key as String) as Number {
        return Hydra.readNumber(key, fallback(key));
    }

    function open() as Void {
        var menu = new WatchUi.Menu2({:title => "Réglages"});
        for (var i = 0; i < KEYS.size(); i++) {
            var key = KEYS[i];
            menu.addItem(new WatchUi.MenuItem(title(key), label(key, current(key)), key, null));
        }
        WatchUi.pushView(menu, new SettingsDelegate(), WatchUi.SLIDE_UP);
    }
}

// Liste principale : Intervalle / Début / Fin / Plus tard
class SettingsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var key = item.getId() as String;
        var values = Settings.options(key);
        var cur = Settings.current(key);
        var focus = 0;
        var menu = new WatchUi.Menu2({:title => Settings.title(key)});
        for (var i = 0; i < values.size(); i++) {
            if (values[i] == cur) { focus = i; }
            menu.addItem(new WatchUi.MenuItem(Settings.label(key, values[i]), null, values[i], null));
        }
        menu.setFocus(focus);
        WatchUi.pushView(menu, new ChoiceDelegate(key, item), WatchUi.SLIDE_LEFT);
    }
}

// Liste des valeurs pour un réglage
class ChoiceDelegate extends WatchUi.Menu2InputDelegate {

    private var _key as String;
    private var _parent as WatchUi.MenuItem;

    function initialize(key as String, parent as WatchUi.MenuItem) {
        Menu2InputDelegate.initialize();
        _key = key;
        _parent = parent;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var value = item.getId() as Number;
        Application.Properties.setValue(_key, value);
        _parent.setSubLabel(Settings.label(_key, value));
        if (_key.equals("intervalMin")) {
            Hydra.reschedule();
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
