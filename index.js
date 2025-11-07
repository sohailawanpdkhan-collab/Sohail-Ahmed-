const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.paymentWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const payload = req.body;
    // TODO: validate webhook signature from your payment gateway

    const userId = payload.userId || payload.customer_id || payload.uid;
    const plan = payload.plan || '30d';
    const amount = payload.amount || 0;

    const now = admin.firestore.Timestamp.now();
    const expiresAt = admin.firestore.Timestamp.fromMillis(Date.now() + daysForPlan(plan));

    const subRef = admin.firestore().collection('subscriptions').doc();
    await subRef.set({
      id: subRef.id,
      userId,
      provider: 'paytabs',
      plan,
      amountSAR: amount,
      status: 'active',
      startedAt: now,
      expiresAt,
      providerPayload: payload
    });

    await admin.firestore().collection('users').doc(userId).set({ vipExpiresAt: expiresAt, role: 'vip' }, { merge: true });

    res.status(200).send('OK');
  } catch (err) {
    console.error(err);
    res.status(500).send('Error');
  }
});

function daysForPlan(plan) {
  if (plan === '30d') return 30 * 24*3600*1000;
  if (plan === '90d') return 90 * 24*3600*1000;
  if (plan === '180d') return 180 * 24*3600*1000;
  if (plan === 'year') return 365 * 24*3600*1000;
  return 0;
}
