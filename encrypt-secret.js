const sodium = require('tweetsodium');

// Repository public key
const publicKey = 'WToU7cZ4HWc6ZtmTpqzl4r8PRSkHidwQYAPwUunEMDw=';
const keyId = '3380204578043523366';

// The secret value (private key)
const secretValue = '0xd7be96c93eb32fa9f1e118764de552dadb49d350a0963a94b4e3c2d7ee6b0e0f';

// Encrypt the secret
const messageBytes = Buffer.from(secretValue);
const keyBytes = Buffer.from(publicKey, 'base64');
const encryptedBytes = sodium.seal(messageBytes, keyBytes);
const encrypted = Buffer.from(encryptedBytes).toString('base64');

console.log('ENCRYPTED_SECRET=' + encrypted);
console.log('KEY_ID=' + keyId);
