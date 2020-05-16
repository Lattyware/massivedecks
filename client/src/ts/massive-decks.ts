import "./material";
import "./paper";
import * as serverConnection from "./server-connection";
import * as speech from "./speech";
import * as notificationManager from "./notification-manager";
import * as settings from "./settings";
import * as copy from "./copy";
import * as language from "./language";
import * as confetti from "./confetti";

export function load(remoteMode: boolean) {
  // This lets us chunk off our elm code separately, which is important so we can
  // use optimisations that will only be valid on pure code.
  import(/* webpackChunkName: "massive-decks" */ "../elm/MassiveDecks").then(
    ({ Elm: elm }) => {
      const app = elm.MassiveDecks.init({
        flags: {
          ...settings.flags(),
          ...language.flags(),
          remoteMode,
        },
      });

      serverConnection.register(app.ports.serverRecv, app.ports.serverSend);
      speech.register(app.ports.speechVoices, app.ports.speechCommands);
      if (!remoteMode) {
        settings.register(app.ports.storeSettings);
        copy.register(app.ports.copyText);
        notificationManager.register(
          app.ports.notificationState,
          app.ports.notificationCommands
        );
        language.register(app.ports.languageChanged);
        confetti.register(app.ports.startConfetti);
        import(/* webpackChunkName: "cast-client" */ "./cast/client").then(
          (cast) => {
            cast.register(app.ports.tryCast, app.ports.castStatus);
          }
        );
      } else {
        import(/* webpackChunkName: "cast-server" */ "./cast/server").then(
          (cast) => {
            cast.register(app.ports.remoteControl);
          }
        );
      }
    }
  );
}
