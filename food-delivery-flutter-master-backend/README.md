# Zomato Backend

This is an Express-based Node.js backend that provides REST APIs for the Flutter frontend.

## Setup

1. Copy your Firebase service account JSON into this folder and name it `serviceAccountKey.json`.
2. Create a `.env` file based on `.env.example` and set `PORT` and other values.
3. Install dependencies:

```bash
npm install
```

4. Run in development:

```bash
npm run dev
```

## Notes

- The backend uses `firebase-admin` to access Firestore, Auth and Storage. Provide the `serviceAccountKey.json` from your Firebase project.
- Endpoints are under `/api/*`.
