import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Point d'entrée de l'appli. Annotée (:background) car le service
// d'arrière-plan démarre aussi à partir de cette classe.
(:background)
class HydraApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // Le service qui se réveille toutes les X minutes.
    function getServiceDelegate() as [System.ServiceDelegate] {
        return [new HydraService()];
    }

    // « Pense à boire ! » → OUI : l'appli s'ouvre alors que c'est l'heure de boire.
    // On compte le verre tout de suite, on montre la goutte 3 s, puis on referme.
    // Sinon (ouverture à la main) : écran principal normal.
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        Hydra.setup();
        if (Hydra.isDue()) {
            Hydra.drink();
            return [new MainView(true), new QuickDelegate()];
        }
        return [new MainView(false), new MainDelegate()];
    }

    // Réglages modifiés depuis l'appli Garmin Connect sur le téléphone.
    function onSettingsChanged() as Void {
        Hydra.reschedule();
        WatchUi.requestUpdate();
    }
}
