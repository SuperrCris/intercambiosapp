# Firestore Setup Instructions

## 1. Enable Firestore in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **intercambiosapp**
3. In the left menu, click **"Firestore Database"**
4. Click **"Create database"**
5. Choose **"Start in test mode"** (we'll set proper rules next)
6. Select your preferred location (choose closest to your users, e.g., **us-central**)
7. Click **"Enable"**

## 2. Enable Firebase Storage

1. In Firebase Console, click **"Storage"** in the left menu
2. Click **"Get started"**
3. Click **"Next"** (accept default rules for now)
4. Select the same location as Firestore
5. Click **"Done"**

## 3. Set Firestore Security Rules

In Firebase Console → Firestore Database → Rules tab, paste this:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Allow anyone to read participants
    match /participantes/{participantId} {
      allow read: if true;
      
      // Allow create only if document doesn't exist yet (prevents duplicates)
      allow create: if !exists(/databases/$(database)/documents/participantes/$(participantId));
      
      // No updates or deletes
      allow update, delete: if false;
    }
  }
}
```

Click **"Publish"**

## 4. Set Storage Security Rules

In Firebase Console → Storage → Rules tab, paste this:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Allow anyone to read photos
    match /{allPaths=**} {
      allow read: if true;
    }
    
    // Allow uploads of PNG files up to 5MB with 8-digit numeric names
    match /{participantId}.png {
      allow create: if request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType == 'image/png'
                   && participantId.matches('^[0-9]{8}$');
      
      // No updates or deletes
      allow update, delete: if false;
    }
  }
}
```

Click **"Publish"**

## 5. Verify Setup

Your app is now ready to use Firestore! The code is already configured to:

- Generate unique 8-digit IDs
- Store participant data in `participantes` collection
- Upload photos to Storage as `{id}.png`
- Show the generated ID to users

## Database Structure

**Collection: `participantes`**

Each document ID is the 8-digit participant ID:
```
participantes/
  └── 12345678/
      ├── nombre: "Juan"
      ├── photoUrl: "https://firebasestorage.../12345678.png"
      └── createdAt: Timestamp
```

## Testing

1. Run your app: `flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080`
2. Click "Participar"
3. Enter a name and optionally select a photo
4. Click "🎁 Participar"
5. You should see the generated ID in a dialog
6. Check Firebase Console → Firestore Database to see the new participant

## Troubleshooting

If you get errors:
- Make sure Firestore is enabled in Firebase Console
- Check that security rules are published
- Verify your `firebase_options.dart` is up to date
- Run `flutter pub get` to ensure packages are installed
