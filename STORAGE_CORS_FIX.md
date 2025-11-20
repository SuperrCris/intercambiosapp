# Firebase Storage CORS Fix

If images are failing to load, you need to configure CORS for Firebase Storage.

## Steps to Fix CORS:

1. **Install Google Cloud SDK** (if not already installed):
   - Download from: https://cloud.google.com/sdk/docs/install
   - Or use: `choco install gcloudsdk` (if you have Chocolatey)

2. **Authenticate with Google Cloud**:
   ```bash
   gcloud auth login
   ```

3. **Set your Firebase project**:
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```
   Replace `YOUR_PROJECT_ID` with your Firebase project ID (check `firebase_options.dart` or Firebase Console)

4. **Apply CORS configuration**:
   ```bash
   gsutil cors set cors.json gs://YOUR_PROJECT_ID.appspot.com
   ```

5. **Verify CORS is set**:
   ```bash
   gsutil cors get gs://YOUR_PROJECT_ID.appspot.com
   ```

## Alternative: Update Security Rules

In Firebase Console → Storage → Rules, ensure your rules allow public read access:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Check if it's working:

After applying CORS, refresh your app and the images should load properly. The code now includes:
- Loading spinner while images download
- Error handling with fallback emoji if image fails to load
- Proper circular clipping for images
