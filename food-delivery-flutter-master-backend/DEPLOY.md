Deployment notes

1) Recommended hosts: Render, Railway, Heroku, Fly, Vercel (Serverless not recommended due to Firebase Admin requiring long-lived credentials).

2) Required environment variables:
   - `PORT` (optional, host will provide)
   - `SERVICE_ACCOUNT_JSON` (the Firebase service account JSON as raw JSON or base64-encoded)

3) Quick Heroku steps:
   - `heroku create your-app-name`
   - `heroku config:set SERVICE_ACCOUNT_JSON="$(cat path/to/serviceAccountKey.json | base64)"`
   - `git push heroku main`

4) Quick Render steps (static Web Service):
   - Create new Web Service, link repo, set `SERVICE_ACCOUNT_JSON` in Environment, set build command `npm install` and start command `node server.js`.

5) Verify:
   - Visit `https://<your-host>/` should return `{ ok: true, firebaseInitialized: true }` if configured correctly.

6) Notes:
   - Keep your service account secret out of the repo.
   - For local dev, place `serviceAccountKey.json` in the backend folder or add `SERVICE_ACCOUNT_FILE=./serviceAccountKey.json` to `.env`.
