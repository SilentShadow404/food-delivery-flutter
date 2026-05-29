const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { randomUUID } = require('crypto');

/**
 * Convert Firestore Timestamp objects (and nested ones) to ISO-8601 strings
 * so Flutter's DateTime.parse() can handle them.
 */
function serializeDoc(data) {
  if (!data || typeof data !== 'object') return data;
  if (typeof data.toDate === 'function') return data.toDate().toISOString();
  if (Array.isArray(data)) return data.map(serializeDoc);
  const out = {};
  for (const [k, v] of Object.entries(data)) {
    out[k] = serializeDoc(v);
  }
  return out;
}

// POST /api/orders — place a new order
router.post('/', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const order = req.body || {};
    const id = order.id || randomUUID();
    // Store createdAt as ISO string — avoids Firestore Timestamp serialization issues
    const now = new Date().toISOString();
    const toSave = { ...order, id, createdAt: now, status: order.status || 'pending' };
    await db.collection('orders').doc(id).set(toSave);
    return res.json({ order: toSave });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

// GET /api/orders/all — all orders (admin)
// Must be declared BEFORE /customer and /vendor to avoid route conflicts.
router.get('/all', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const snap = await db.collection('orders').get();
    const orders = snap.docs
      .map((d) => serializeDoc(d.data()))
      .sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
    return res.json({ orders });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

// GET /api/orders/customer/:customerId
// Equality filter only — no orderBy — no composite index needed.
router.get('/customer/:customerId', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const snap = await db.collection('orders')
      .where('customerId', '==', req.params.customerId)
      .get();
    const orders = snap.docs
      .map((d) => serializeDoc(d.data()))
      .sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
    return res.json({ orders });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

// GET /api/orders/vendor/:vendorId
// Equality filter only — no orderBy — no composite index needed.
router.get('/vendor/:vendorId', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const snap = await db.collection('orders')
      .where('vendorId', '==', req.params.vendorId)
      .get();
    const orders = snap.docs
      .map((d) => serializeDoc(d.data()))
      .sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
    return res.json({ orders });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

// PATCH /api/orders/:id/status — update order status (persisted to Firestore)
router.patch('/:id/status', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const { status } = req.body;
    if (!status) return res.status(400).json({ error: 'status is required' });
    const update = { status };
    if (status === 'delivered') update.deliveredAt = new Date().toISOString();
    await db.collection('orders').doc(req.params.id).update(update);
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

// DELETE /api/orders/:id — cancel an order
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
