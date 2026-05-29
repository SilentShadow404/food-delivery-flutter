const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const bcrypt = require('bcrypt');

router.post('/register', async (req, res) => {
  try {
    const { email, password, name, phone, role, address, restaurantName, restaurantDescription } = req.body;

    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    if (!email || !password || !name) return res.status(400).json({ error: 'Missing required fields' });

    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
      phoneNumber: phone,
    });

    const db = admin.firestore();
    // Hash password before saving to Firestore
    const hashedPassword = await bcrypt.hash(password, 10);

    const userDoc = {
      id: userRecord.uid,
      name,
      email,
      phone,
      role: role || 'customer',
      isActive: true,
      profileImage: 'assets/images/profile.jpeg',
      address: address || '',
      password: hashedPassword,
      restaurantName: restaurantName || '',
      restaurantDescription: restaurantDescription || '',
      restaurantRating: role === 'vendor' ? 0 : null,
      isApproved: role === 'vendor' ? false : null,
      createdAt: new Date(),
    };

    await db.collection('users').doc(userRecord.uid).set(userDoc);
    return res.json({ user: userDoc });
  } catch (e) {
    console.error(e);
    return res.status(400).json({ error: e.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password, role } = req.body;
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    // Require role for disambiguation between customer/vendor/admin
    if (!role) return res.status(400).json({ error: 'Role is required for login' });

    const q = await db.collection('users').where('email', '==', email).where('role', '==', role).limit(1).get();
    if (q.empty) return res.status(404).json({ error: 'User not found' });
    const data = q.docs[0].data();
    const match = await bcrypt.compare(password, data.password || '');
    if (!match) return res.status(401).json({ error: 'Invalid email or password' });
    return res.json({ user: data });
  } catch (e) {
    console.error(e);
    return res.status(400).json({ error: e.message });
  }
});

// Seed endpoint to create test users: admin, vendor, customer
router.post('/seed', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();

    const users = [
      { email: 'admin@food.com', password: 'admin123', name: 'Admin User', role: 'admin' },
      { email: 'vendor@food.com', password: 'vendor123', name: 'Test Vendor', role: 'vendor' },
      { email: 'customer@food.com', password: 'customer123', name: 'Test Customer', role: 'customer' },
    ];

    const created = [];
    for (const u of users) {
      // Check if exists
      const q = await db.collection('users').where('email', '==', u.email).limit(1).get();
      if (!q.empty) {
        created.push({ email: u.email, ok: false, reason: 'already exists' });
        continue;
      }

      // Create auth user
      const userRecord = await admin.auth().createUser({
        email: u.email,
        password: u.password,
        displayName: u.name,
      });

      const hashed = await bcrypt.hash(u.password, 10);
      const doc = {
        id: userRecord.uid,
        name: u.name,
        email: u.email,
        phone: '',
        role: u.role,
        isActive: true,
        profileImage: 'assets/images/profile.jpeg',
        address: '',
        password: hashed,
        restaurantName: u.role === 'vendor' ? 'Demo Restaurant' : '',
        restaurantDescription: u.role === 'vendor' ? 'Demo desc' : '',
        restaurantRating: u.role === 'vendor' ? 0 : null,
        isApproved: u.role === 'vendor' ? false : null,
        createdAt: new Date(),
      };

      await db.collection('users').doc(userRecord.uid).set(doc);
      created.push({ email: u.email, ok: true });
    }

    return res.json({ created });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.get('/users', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const snap = await db.collection('users').get();
    const users = snap.docs
      .map((d) => d.data())
      .sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
    return res.json({ users });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.patch('/users/:id', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    await db.collection('users').doc(req.params.id).set(req.body, { merge: true });
    const updated = await db.collection('users').doc(req.params.id).get();
    return res.json({ user: updated.data() });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

/**
 * POST /api/auth/provision
 * Provisions a Firestore user document for an account that already exists in
 * Firebase Authentication (e.g. created manually via the Firebase console).
 *
 * Body: { email, name, role, password, phone?, restaurantName?, restaurantDescription? }
 *
 * - Looks up the existing Firebase Auth user by email
 * - Updates their password in Firebase Auth to the one supplied
 * - Creates (or overwrites) the Firestore /users/<uid> document with the
 *   correct schema so the app can log them in and respect their role
 */
router.post('/provision', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });

    const { email, name, role, password, phone, restaurantName, restaurantDescription } = req.body;
    if (!email || !name || !role || !password) {
      return res.status(400).json({ error: 'email, name, role, and password are required' });
    }

    const validRoles = ['admin', 'vendor', 'customer'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({ error: `role must be one of: ${validRoles.join(', ')}` });
    }

    // Look up the existing Firebase Auth user by email
    let userRecord;
    try {
      userRecord = await admin.auth().getUserByEmail(email);
    } catch (lookupErr) {
      return res.status(404).json({
        error: `No Firebase Auth user found for "${email}". Create the auth account first via the Firebase console or /api/auth/register.`,
      });
    }

    // Update the password in Firebase Auth so it matches what we hash in Firestore
    await admin.auth().updateUser(userRecord.uid, { password, displayName: name });

    const db = admin.firestore();
    const hashedPassword = await bcrypt.hash(password, 10);

    const userDoc = {
      id: userRecord.uid,
      name,
      email,
      phone: phone || '',
      role,
      isActive: true,
      profileImage: 'assets/images/profile.jpeg',
      password: hashedPassword,
      restaurantName: role === 'vendor' ? (restaurantName || '') : '',
      restaurantDescription: role === 'vendor' ? (restaurantDescription || '') : '',
      restaurantRating: role === 'vendor' ? 0 : null,
      isApproved: role === 'vendor' ? false : null,
      createdAt: new Date(),
    };

    await db.collection('users').doc(userRecord.uid).set(userDoc);
    return res.json({ user: userDoc });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

/**
 * POST /api/auth/forgot-password
 * Sends a password reset email via Firebase Auth REST API.
 *
 * Why the backend and not Flutter directly:
 *   Flutter's firebase_auth targets the 'zomato-101e9' project.
 *   All user accounts were created in 'food-delivery-e78ef' (the Admin SDK
 *   project).  Flutter therefore always gets "user-not-found" and no email
 *   is ever sent.  The backend Admin SDK IS connected to food-delivery-e78ef,
 *   so the REST API call here targets the correct project.
 *
 * Requires env var: FIREBASE_WEB_API_KEY  (Project Settings → General in
 * the Firebase console for food-delivery-e78ef)
 */
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body || {};
  if (!email) return res.status(400).json({ error: 'email is required' });

  const apiKey = process.env.FIREBASE_WEB_API_KEY;
  if (!apiKey) {
    console.error('[forgot-password] FIREBASE_WEB_API_KEY env var is not set');
    return res.status(500).json({ error: 'Password reset is not configured on the server' });
  }

  try {
    const response = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ requestType: 'PASSWORD_RESET', email }),
      }
    );
    const data = await response.json();
    if (!response.ok) {
      // Log internally but never tell the caller whether the email exists
      console.error('[forgot-password] Firebase REST error:', data?.error?.message);
    }
    // Always respond with ok=true to prevent email-enumeration attacks
    return res.json({ ok: true });
  } catch (e) {
    console.error('[forgot-password]', e.message);
    return res.status(500).json({ error: 'Failed to send reset email' });
  }
});

module.exports = router;
