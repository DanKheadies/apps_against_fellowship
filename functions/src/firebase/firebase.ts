import * as admin from "firebase-admin";
import * as games from "./data/games";
import * as cards from "./data/cards";
import * as messages from "./data/messages";
import * as players from "./data/players";
import * as push from "./push";

// Hydrate our context of Firebase Admin SDK
admin.initializeApp();

const firestore = admin.firestore();
const messaging = admin.messaging();

export {games, cards, messages, players, push, firestore, messaging};
