const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.listUsers = functions.https.onCall(async (data, context) => {
  try {
    // Check if the request is from an authenticated admin user
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Check if the user is an admin (you can customize this logic)
    const adminDoc = await admin.firestore().collection('admins').doc(context.auth.uid).get();
    if (!adminDoc.exists) {
      throw new functions.https.HttpsError('permission-denied', 'User is not an admin');
    }

    // List all users from Firebase Auth
    const listUsersResult = await admin.auth().listUsers();
    
    // Format the users data
    const users = listUsersResult.users.map(user => ({
      uid: user.uid,
      email: user.email,
      displayName: user.displayName || user.email?.split('@')[0] || 'Unknown',
      emailVerified: user.emailVerified,
      disabled: user.disabled,
      creationTime: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
      providerData: user.providerData,
    }));

    return { users };
  } catch (error) {
    console.error('Error listing users:', error);
    throw new functions.https.HttpsError('internal', 'Error listing users');
  }
});
