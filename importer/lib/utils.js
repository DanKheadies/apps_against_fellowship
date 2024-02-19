"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.hashDocumentId = exports.computeCardId = exports.cleanPath = void 0;
const crypto = require('crypto');
function cleanPath(input) {
    return input.replace('/', '_');
}
exports.cleanPath = cleanPath;
function computeCardId(set, cardText) {
    const hash = crypto.createHash('sha256');
    hash.update(set + cardText);
    return hash.digest('hex');
}
exports.computeCardId = computeCardId;
function hashDocumentId(input) {
    const hash = crypto.createHash('sha256');
    hash.update(input);
    return hash.digest('hex');
}
exports.hashDocumentId = hashDocumentId;
//# sourceMappingURL=utils.js.map