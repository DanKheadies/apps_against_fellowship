import { CardSet, PromptCard } from './models';
import { computeCardId, cleanPath, hashDocumentId } from './utils';

import * as admin from 'firebase-admin';
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';
import { JWT } from 'google-auth-library';
import {
    GoogleSpreadsheet,
    GoogleSpreadsheetWorksheet,
} from 'google-spreadsheet';

const client = new SecretManagerServiceClient();

// Sheet Variables
const promptLength = 6954;
const responseLength = 25163;
const docId = '1lsy7lIwBe-DWOi2PALZPf5DgXHx9MEvKfRw1GaWQkzg';
const sheetId = '2018240023';
const cardSetOnly = false;

// const emulator = false;
// if (emulator) {
//     process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
// }

admin.initializeApp();
const db = admin.firestore();

export const accessSecret = async () => {
    const [version] = await client.accessSecretVersion({
        name: 'projects/69402188680/secrets/aaf-jwt/versions/1',
    });
    const payload = version.payload?.data?.toString() ?? 'derp';
    // console.log(`Secret data: ${payload}`);
    const result = JSON.parse(payload!);
    const params = {
        type: result.type,
        projectId: result.project_id,
        privateKeyId: result.private_key_id,
        privateKey: result.private_key,
        clientEmail: result.client_email,
        clientId: result.client_id,
        authUri: result.auth_uri,
        tokenUri: result.token_uri,
        authProviderX509CertUrl: result.auth_provider_x509_cert_url,
        clientC509CertUrl: result.client_x509_cert_url,
    };
    // console.log('params');
    // console.log(params);
    // return payload;
    return params;
};

async function loadAndSavePromptCards(sheet: GoogleSpreadsheetWorksheet) {
    // Let's load all the prompts
    await sheet.loadCells(`A2:D${promptLength}`);
    console.log('Prompt cells loaded');

    const prompts = new Map<string, [CardSet, PromptCard[]]>();

    for (let i = 2; i <= promptLength; i++) {
        const promptText = sheet.getCellByA1(`A${i}`).value as string;
        const promptSpecial = sheet.getCellByA1(`B${i}`).value as string;
        const promptSet = sheet.getCellByA1(`C${i}`).value as string;
        const sourceSheet = sheet.getCellByA1(`D${i}`).value as string;

        if (promptText && promptText.length > 0) {
            const cid = computeCardId(promptSet, promptText);
            let cards = prompts.get(promptSet);
            if (!cards) {
                const newSet: CardSet = {
                    id: cleanPath(promptSet),
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
            .doc(cleanPath(promptSet));

        // Set the set master document
        await cardSetDocument.set(
            {
                name: promptSet,
                source: cards[0].source,
                prompts: cards[1].length,
                promptIndexes: cards[1].map((card) => card.cid),
            },
            { merge: true },
        );

        if (!cardSetOnly) {
            const promptsCollection = cardSetDocument.collection('prompts');
            let currentBatchCount = 0;
            let batch = db.batch();
            for (let prompt of cards[1]) {
                try {
                    const document = promptsCollection.doc(
                        hashDocumentId(prompt.text),
                    );
                    if (currentBatchCount >= 500) {
                        await batch.commit();
                        batch = db.batch();
                        currentBatchCount = 0;
                        console.log('Batch committed to Firebase');
                    }
                    batch.set(document, prompt);
                    currentBatchCount += 1;
                } catch (e) {
                    console.log('Error processing prompt card: ' + e);
                }
            }
            await batch.commit();
        }
    }
}

async function loadAndSaveResponseCards(sheet: GoogleSpreadsheetWorksheet) {
    // Let's load all the prompts
    await sheet.loadCells(`G2:I${responseLength}`);
    console.log('Response cells loaded');

    const responses = new Map<string, [CardSet, PromptCard[]]>();

    for (let i = 2; i <= responseLength; i++) {
        const responseText = sheet
            .getCellByA1(`G${i}`)
            .value?.toString() as string;
        const responseSet = sheet.getCellByA1(`H${i}`).value as string;
        const sourceSheet = sheet.getCellByA1(`I${i}`).value as string;

        if (responseText && responseText.length > 0) {
            const cid = computeCardId(responseSet, responseText);
            let cards = responses.get(responseSet);
            if (!cards) {
                const newSet: CardSet = {
                    id: cleanPath(responseSet),
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
            .doc(cleanPath(responseSet));

        await cardSetDocument.set(
            {
                name: responseSet,
                source: cards[0].source,
                responses: cards[1].length,
                responseIndexes: cards[1].map((card) => card.cid),
            },
            { merge: true },
        );

        if (!cardSetOnly) {
            const responsesCollection = cardSetDocument.collection('responses');
            let currentBatchCount = 0;
            let batch = db.batch();
            for (let response of cards[1]) {
                try {
                    const document = responsesCollection.doc(
                        hashDocumentId(response.text),
                    );
                    if (currentBatchCount >= 500) {
                        await batch.commit();
                        batch = db.batch();
                        currentBatchCount = 0;
                        console.log('Batch committed to Firebase');
                    }
                    batch.set(document, response);
                    currentBatchCount += 1;
                } catch (e) {
                    console.log('Error processing response card: ' + e);
                }
            }
            await batch.commit();
        }
    }
}

async function run(docId: string) {
    const secret = await accessSecret();

    const jwt = new JWT({
        email: secret.clientEmail,
        key: secret.privateKey,
        scopes: ['https://www.googleapis.com/auth/spreadsheets'],
    });

    const doc = new GoogleSpreadsheet(docId, jwt);
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

run(docId);
