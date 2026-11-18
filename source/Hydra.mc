import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

// Toute la logique : compteur du jour, dernier verre, programmation des rappels.
module Hydra {

    // --- Réglages -------------------------------------------------------

    function readNumber(key as String, fallback as Number) as Number {
        var value = null;
        try {
            value = Application.Properties.getValue(key);
        } catch (e) {
        }
        return (value instanceof Number) ? value : fallback;
    }

    function intervalSec() as Number {
        var minutes = readNumber("intervalMin", 45);
        if (minutes < 15) { minutes = 15; }
        return minutes * 60;
    }

    // --- Données enregistrées ------------------------------------------

    function now() as Number {
        return Time.now().value();
    }

    function storedNumber(key as String) as Number {
        var value = Application.Storage.getValue(key);
        return (value instanceof Number) ? value : 0;
    }

    function today() as Number {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return (info.year as Number) * 10000 + (info.month as Number) * 100 + (info.day as Number);
    }

    // Remet le compteur à zéro quand on change de jour.
    function rollDay() as Void {
        if (storedNumber("day") != today()) {
            Application.Storage.setValue("day", today());
            Application.Storage.setValue("count", 0);
        }
    }

    function count() as Number {
        rollDay();
        return storedNumber("count");
    }

    // --- Programmation -------------------------------------------------

    function setup() as Void {
        rollDay();
        if (Application.Storage.getValue("last") == null) {
            Application.Storage.setValue("last", now());
        }
        if (Background.getTemporalEventRegisteredTime() == null) {
            reschedule();
        }
    }

    function reschedule() as Void {
        try {
            Background.registerForTemporalEvent(new Time.Duration(intervalSec()));
        } catch (e) {
        }
    }

    function inActiveHours() as Boolean {
        var hour = System.getClockTime().hour;
        return hour >= readNumber("startHour", 8) && hour < readNumber("endHour", 21);
    }

    // C'est l'heure de boire si le dernier verre date d'au moins un intervalle
    // (à une minute près), pendant les heures de rappel.
    function isDue() as Boolean {
        return inActiveHours() && (now() - storedNumber("last")) >= intervalSec() - 60;
    }

    // --- Actions -------------------------------------------------------

    // J'ai bu : +1 et le prochain rappel repart d'un intervalle complet.
    function drink() as Void {
        Application.Storage.setValue("count", count() + 1);
        Application.Storage.setValue("last", now());
        reschedule();
    }

    // Heure approximative du prochain rappel, pour l'affichage.
    function nextReminder() as Number {
        var t = now();
        var next = storedNumber("last") + intervalSec();
        return (next > t) ? next : t;
    }

    function formatTime(epoch as Number) as String {
        var info = Gregorian.info(new Time.Moment(epoch), Time.FORMAT_SHORT);
        return Lang.format("$1$:$2$", [
            (info.hour as Number).format("%02d"),
            (info.min as Number).format("%02d")
        ]);
    }
}
