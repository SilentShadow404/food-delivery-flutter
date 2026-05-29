const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

function initFirebase(serviceAccountPath) {
  let serviceAccount = null;

  // 1) Prefer raw JSON provided in SERVICE_ACCOUNT_JSON (useful for hosting providers)
  if (process.env.SERVICE_ACCOUNT_JSON) {
    try {
      serviceAccount = JSON.parse(process.env.SERVICE_ACCOUNT_JSON);
    } catch (e) {
      try {
        // If the value is base64-encoded JSON, decode then parse
        const decoded = Buffer.from(process.env.SERVICE_ACCOUNT_JSON, 'base64').toString('utf8');
        serviceAccount = JSON.parse(decoded);
      } catch (err) {
        console.warn('Failed to parse SERVICE_ACCOUNT_JSON:', err.message);
      }
    }
  }

  // 2) Fallback to file path if provided and exists
  if (!serviceAccount && serviceAccountPath) {
    try {
      const resolved = path.isAbsolute(serviceAccountPath)
        ? serviceAccountPath
        : path.resolve(__dirname, serviceAccountPath);
      if (fs.existsSync(resolved)) {
        serviceAccount = require(resolved);
      }
    } catch (e) {
      console.warn('Failed to load service account file:', e.message);
    }
  }

  if (!serviceAccount) {
    console.warn('Firebase service account key not found. Firebase Admin will not be initialized.');
    return null;
  }

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }
  return admin;
}

module.exports = { initFirebase };
