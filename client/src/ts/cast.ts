//import "../html/cast.html";
import { Server as CastServer } from "./chromecast";

import(/* webpackChunkName: "massive-decks" */ "../elm/MassiveDecks").then(
  ({ Elm: elm }) => {
    new CastServer(castFlags =>
      elm.MassiveDecks.Cast.init({ flags: castFlags })
    );
  }
);
