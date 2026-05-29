const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { randomUUID } = require('crypto');

router.get('/', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    let query = db.collection('food_items').where('isAvailable', '==', true);
    if (req.query.category) query = query.where('category', '==', req.query.category);
    if (req.query.vendorId) query = query.where('vendorId', '==', req.query.vendorId);

    const snap = await query.get();
    const foods = snap.docs.map((d) => d.data());
    return res.json({ foods });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.post('/', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const item = req.body || {};
    const id = item.id || randomUUID();
    const now = new Date();
    const toSave = Object.assign({ id, createdAt: now, isAvailable: true }, item);
    await db.collection('food_items').doc(id).set(toSave);
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    await db.collection('food_items').doc(req.params.id).update(req.body);
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    await db.collection('food_items').doc(req.params.id).delete();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
