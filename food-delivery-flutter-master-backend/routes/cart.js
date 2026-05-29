const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

router.get('/:customerId', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const snap = await db.collection('cart').where('customerId', '==', req.params.customerId).get();
    const items = [];
    for (const d of snap.docs) {
      const data = d.data();
      const foodDoc = await db.collection('food_items').doc(data.foodId).get();
      const food = foodDoc.exists ? foodDoc.data() : null;
      items.push({ food, quantity: data.quantity });
    }
    return res.json({ items });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.post('/:customerId', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const { foodId, quantity } = req.body;
    const docId = `${req.params.customerId}_${foodId}`;
    await db.collection('cart').doc(docId).set({ customerId: req.params.customerId, foodId, quantity, addedAt: new Date() });
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

router.delete('/:customerId/:foodId', async (req, res) => {
  try {
    if (!admin.apps.length) return res.status(500).json({ error: 'Firebase not configured' });
    const db = admin.firestore();
    const docId = `${req.params.customerId}_${req.params.foodId}`;
    await db.collection('cart').doc(docId).delete();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

module.exports = router;
