"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const utils_1 = require("./utils");
// const { GoogleSpreadsheet } = require('google-spreadsheet');
// import {GoogleSpreadsheet} from 'google-spreadsheet';
const google_spreadsheet_1 = require("google-spreadsheet");
const google_auth_library_1 = require("google-auth-library");
const admin = require("firebase-admin");
const argv = require('minimist')(process.argv.slice(2));
console.log(argv);
// Sheet Variables
const promptLength = argv.pl || 6792;
const responseLength = argv.rl || 24413;
const documentId = argv.doc || '1lsy7lIwBe-DWOi2PALZPf5DgXHx9MEvKfRw1GaWQkzg';
const sheetId = argv.sheet || '2018240023';
const cardSetOnly = argv['set-only'] || false;
const emulator = argv['emulator'] || false;
if (emulator) {
    process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
}
const serviceAccount = require('../config/firebase_admin_sdk.json');
// import * as serviceAccount from '../config/firebase_admin_sdk.json';
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://apps-against-fellowship-default-rtdb.firebaseio.com/',
});
const db = admin.firestore();
// @ts-ignore
async function loadAndSavePromptCards(sheet) {
    // Let's load all the prompts
    await sheet.loadCells(`A2:D${promptLength}`);
    console.log('Prompt cells loaded');
    const prompts = new Map();
    for (let i = 2; i <= promptLength; i++) {
        const promptText = sheet.getCellByA1(`A${i}`).value;
        const promptSpecial = sheet.getCellByA1(`B${i}`).value;
        const promptSet = sheet.getCellByA1(`C${i}`).value;
        const sourceSheet = sheet.getCellByA1(`D${i}`).value;
        if (promptText && promptText.length > 0) {
            const cid = (0, utils_1.computeCardId)(promptSet, promptText);
            let cards = prompts.get(promptSet);
            if (!cards) {
                const newSet = {
                    id: (0, utils_1.cleanPath)(promptSet),
                    set: promptSet,
                    source: sourceSheet,
                };
                cards = [newSet, []];
            }
            cards[1].push({
                cid: cid,
                text: promptText,
                special: promptSpecial,
                set: promptSet,
                source: sourceSheet,
            });
            prompts.set(promptSet, cards);
        }
    }
    for (let [promptSet, cards] of prompts) {
        const cardSetDocument = db
            .collection('cardSets')
            .doc((0, utils_1.cleanPath)(promptSet));
        // Set the set master document
        await cardSetDocument.set({
            name: promptSet,
            source: cards[0].source,
            prompts: cards[1].length,
            promptIndexes: cards[1].map((card) => card.cid),
        }, { merge: true });
        if (!cardSetOnly) {
            const promptsCollection = cardSetDocument.collection('prompts');
            let currentBatchCount = 0;
            let batch = db.batch();
            for (let prompt of cards[1]) {
                try {
                    const document = promptsCollection.doc((0, utils_1.hashDocumentId)(prompt.text));
                    if (currentBatchCount >= 500) {
                        await batch.commit();
                        batch = db.batch();
                        currentBatchCount = 0;
                        console.log('Batch committed to Firebase');
                    }
                    batch.set(document, prompt);
                    currentBatchCount += 1;
                }
                catch (e) {
                    console.log('Error processing prompt card: ' + e);
                }
            }
            await batch.commit();
        }
    }
}
// @ts-ignore
async function loadAndSaveResponseCards(sheet) {
    var _a;
    // Let's load all the prompts
    await sheet.loadCells(`G2:I${responseLength}`);
    console.log('Response cells loaded');
    const responses = new Map();
    for (let i = 2; i <= responseLength; i++) {
        const responseText = (_a = sheet.getCellByA1(`G${i}`).value) === null || _a === void 0 ? void 0 : _a.toString();
        const responseSet = sheet.getCellByA1(`H${i}`).value;
        const sourceSheet = sheet.getCellByA1(`I${i}`).value;
        if (responseText && responseText.length > 0) {
            const cid = (0, utils_1.computeCardId)(responseSet, responseText);
            let cards = responses.get(responseSet);
            if (!cards) {
                const newSet = {
                    id: (0, utils_1.cleanPath)(responseSet),
                    set: responseSet,
                    source: sourceSheet,
                };
                cards = [newSet, []];
            }
            cards[1].push({
                cid: cid,
                text: responseText,
                set: responseSet,
                source: sourceSheet,
            });
            responses.set(responseSet, cards);
        }
    }
    for (let [responseSet, cards] of responses) {
        const cardSetDocument = db
            .collection('cardSets')
            .doc((0, utils_1.cleanPath)(responseSet));
        await cardSetDocument.set({
            name: responseSet,
            source: cards[0].source,
            responses: cards[1].length,
            responseIndexes: cards[1].map((card) => card.cid),
        }, { merge: true });
        if (!cardSetOnly) {
            const responsesCollection = cardSetDocument.collection('responses');
            let currentBatchCount = 0;
            let batch = db.batch();
            for (let response of cards[1]) {
                try {
                    const document = responsesCollection.doc((0, utils_1.hashDocumentId)(response.text));
                    if (currentBatchCount >= 500) {
                        await batch.commit();
                        batch = db.batch();
                        currentBatchCount = 0;
                        console.log('Batch committed to Firebase');
                    }
                    batch.set(document, response);
                    currentBatchCount += 1;
                }
                catch (e) {
                    console.log('Error processing response card: ' + e);
                }
            }
            await batch.commit();
        }
    }
}
async function run(docId) {
    // const doc = new GoogleSpreadsheet(docId);
    // await doc.useServiceAccountAuth(require('../config/service_account.json'));
    const serviceAccountAuth = new google_auth_library_1.JWT({
        email: process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL,
        key: process.env.GOOGLE_PRIVATE_KEY,
        scopes: ['https://www.googleapis.com/auth/spreadsheets'],
    });
    const doc = new google_spreadsheet_1.GoogleSpreadsheet(docId, serviceAccountAuth);
    await doc.loadInfo();
    console.log(doc.title);
    // Master Cards List Sheet
    const sheet = doc.sheetsById[sheetId];
    console.log(sheet.title);
    console.log(sheet.rowCount);
    // Let's load all the prompts
    console.log('Start loading prompts');
    await loadAndSavePromptCards(sheet);
    console.log("Prompt card's read and written");
    // Let's load all the response cards
    console.log('Start loading responses');
    await loadAndSaveResponseCards(sheet);
    console.log('Finished loading all CaH cards into firestore');
}
run(documentId);
//# sourceMappingURL=main.js.map