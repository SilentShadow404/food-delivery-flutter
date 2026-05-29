const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { randomUUID } = require('crypto');

router.post('/', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const order = req.body || {};
    const id = order.id || randomUUID();
    const now = new Date();
    const toSave = Object.assign({ id, createdAt: now, status: 'pending' }, order);
    await db.collection('orders').doc(id).set(toSave);
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.get('/customer/:customerId', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const snap = await db.collection('orders').where('customerId', '==', req.params.customerId).orderBy('createdAt', 'desc').get();
    const orders = snap.docs.map((d) => d.data());
    return res.json({ orders });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.get('/vendor/:vendorId', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const snap = await db.collection('orders').where('vendorId', '==', req.params.vendorId).orderBy('createdAt', 'desc').get();
    const orders = snap.docs.map((d) => d.data());
    return res.json({ orders });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.patch('/:id/status', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const { status } = req.body;
    if (!status) return res.status(400).json({ error: 'status is required' });
    const update = { status };
    if (status === 'delivered') update.deliveredAt = new Date();
    await db.collection('orders').doc(req.params.id).update(update);
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
    await db.collection('orders').doc(req.params.id).update({ status: 'cancelled' });
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
