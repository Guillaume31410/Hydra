import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

// Tourne en arrière-plan, quelques secondes, à chaque réveil programmé.
// Il ne peut ni dessiner ni vibrer : il demande seulement à la montre
// d'afficher « Pense à boire ! Ouvrir Hydra ? ».
(:background)
class HydraService extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        var hour = System.getClockTime().hour;
        var start = readNumber("startHour", 8);
        var end = readNumber("endHour", 21);

        // Silence si la montre est en mode « Ne pas déranger » (ou en mode sommeil).
        var settings = System.getDeviceSettings();
        var quiet = (settings has :doNotDisturb) && settings.doNotDisturb;

        try {
            if (!quiet && hour >= start && hour < end) {
                Background.requestApplicationWake("Pense à boire !");
                // Sans réponse (ou NON), on considère un report : nouveau rappel
                // dans X minutes. Si tu réponds OUI, l'appli remet le rythme normal.
                var snooze = readNumber("snoozeMin", 10);
                if (snooze < 5) { snooze = 5; }
                Background.registerForTemporalEvent(Time.now().add(new Time.Duration(snooze * 60)));
            } else if (Background.getTemporalEventRegisteredTime() instanceof Time.Moment) {
                // Hors des heures / Ne pas déranger : on revient au rythme normal.
                var minutes = readNumber("intervalMin", 45);
                if (minutes < 15) { minutes = 15; }
                Background.registerForTemporalEvent(new Time.Duration(minutes * 60));
            }
        } catch (e) {
            // L'appli remettra la programmation à sa prochaine ouverture.
        }

        Background.exit(true);
    }

    private function readNumber(key as String, fallback as Number) as Number {
        var value = null;
        try {
            value = Application.Properties.getValue(key);
        } catch (e) {
        }
        return (value instanceof Number) ? value : fallback;
    }
}
