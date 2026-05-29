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
    const snap = await db.collection('users').orderBy('createdAt', 'desc').get();
    const users = snap.docs.map((d) => d.data());
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

module.exports = router;
