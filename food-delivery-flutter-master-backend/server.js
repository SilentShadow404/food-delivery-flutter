require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs');

const { initFirebase } = require('./firebaseAdmin');

// Try env var first, then common filenames, then auto-detect any JSON service account in folder
let SERVICE_ACCOUNT = process.env.SERVICE_ACCOUNT_FILE;
if (!SERVICE_ACCOUNT) {
	const candidates = ['./serviceAccountKey.json', './serviceAccount.json'];
	for (const c of candidates) {
		if (fs.existsSync(path.resolve(__dirname, c))) {
			SERVICE_ACCOUNT = path.resolve(__dirname, c);
			break;
		}
	}
}
// Auto-detect any JSON that looks like a service account (contains "private_key")
if (!SERVICE_ACCOUNT) {
	const files = fs.readdirSync(path.resolve(__dirname));
	for (const f of files) {
		if (f.endsWith('.json')) {
			try {
				const content = fs.readFileSync(path.resolve(__dirname, f), 'utf8');
				if (content.includes('private_key') && content.includes('client_email')) {
					SERVICE_ACCOUNT = path.resolve(__dirname, f);
					break;
				}
			} catch (e) {
				// ignore
			}
		}
	}
}

const admin = initFirebase(SERVICE_ACCOUNT);

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/', (req, res) => res.json({ ok: true, firebaseInitialized: Boolean(admin) }));

app.use('/api/auth', require('./routes/auth'));
app.use('/api/foods', require('./routes/foods'));
app.use('/api/cart', require('./routes/cart'));
app.use('/api/orders', require('./routes/orders'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on http://0.0.0.0:${PORT}`));
