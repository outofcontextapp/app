import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkUserIsSignedIn } from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

/**
 * Delete a user's quotes list.
 */
export const deleteList = functions
  .region('europe-west3')
  .https
  .onCall(async (data: DeleteListParams, context) => {
    const userAuth = context.auth;
    const { listId, idToken } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    if (!listId) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with [listId] argument
         which is the list to delete.`
      );
    }

    const listSnapshot = await firestore
      .collection('users')
      .doc(userAuth.uid)
      .collection('lists')
      .doc(listId)
      .get();

    if (!listSnapshot.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        `This collection doesn't exist anymore. It may have been deleted.`,
      );
    }

    try {
      await firebaseTools.firestore
        .delete(listSnapshot.ref.path, {
          project: process.env.GCLOUD_PROJECT,
          recursive: true,
          yes: true,
        });

      return {
        success: true,
        user: {
          id: userAuth.uid,
        },
        target: {
          type: 'list',
          id: listId,
        }
      };
    } catch (error) {
      console.error(error);

      await firestore
        .collection('todelete')
        .doc(listId)
        .set({
          doc: {
            id: listId,
            conceptualType: 'list',
            dataType: 'subcollection',
            hasChildren: true,
          },
          path: listSnapshot.ref.path,
          user: {
            id: userAuth.uid,
          },
        });

      throw new functions.https.HttpsError(
        'internal',
        `There was an unexpected issue while deleting the list.
        Please try again or contact the support for more information.`,
      );
    }
  });

/**
 * Delete multiple user's lists.
 */
export const deleteLists = functions
  .region('europe-west3')
  .https
  .onCall(async (data: DeleteListsParams, context) => {
    const userAuth = context.auth;
    const { listIds, idToken } = data;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    await checkUserIsSignedIn(context, idToken);

    if (!listIds || listIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with one argument [listIds]
         which is the array of lists to delete.`
      );
    }

    for await (const listId of listIds) {
      const listSnapshot = await firestore
        .collection('users')
        .doc(userAuth.uid)
        .collection('lists')
        .doc(listId)
        .get();
  
      if (!listSnapshot.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          `This collection doesn't exist anymore. It may have been deleted.`,
        );
      }
      
      try {
        await firebaseTools.firestore
          .delete(listSnapshot.ref.path, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
          });

      } catch (error) {
        console.error(error);

        await firestore
          .collection('todelete')
          .doc(listId)
          .set({
            doc: {
              id: listId,
              conceptualType: 'list',
              dataType: 'subcollection',
              hasChildren: true,
            },
            path: listSnapshot.ref.path,
            user: {
              id: userAuth.uid,
            },
          });
      }
    }

    return {
      success: true,
      user: {
        id: userAuth.uid,
      },
      listIds,
    };
  });
