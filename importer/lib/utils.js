"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cleanPath = cleanPath;
exports.computeCardId = computeCardId;
exports.hashDocumentId = hashDocumentId;
const crypto = require('crypto');
function cleanPath(input) {
    return input.replace('/', '_');
}
function computeCardId(set, cardText) {
    const hash = crypto.createHash('sha256');
    hash.update(set + cardText);
    return hash.digest('hex');
}
function hashDocumentId(input) {
    const hash = crypto.createHash('sha256');
    hash.update(input);
    return hash.digest('hex');
}
//# sourceMappingURL=utils.js.map