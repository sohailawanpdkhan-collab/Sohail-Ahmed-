NexaChat Admin Starter
---------------------
This is a minimal placeholder for an admin panel.
For a production admin UI, use Create React App or Next.js and integrate Firebase Admin SDK on server side.

Quick idea:
- Build a page that lists users from Firestore
- Provide controls to set vipExpiresAt or role for a user
- Protect admin routes using Firebase Auth and check user.role === 'admin'
