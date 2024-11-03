/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNewPostNotification = functions.firestore
    .document("posts/{postId}")
    .onCreate(async (snap, context) => {
      try {
        const postData = snap.data();
        if (!postData) {
          console.error("No post data found!");
          return;
        }
        console.log("Post data fetched successfully:", postData);

        const channelId = postData.channelId;
        console.log("Channel ID:", channelId);

        const channelDoc = await admin.firestore().
            collection("channels").doc(channelId).get();
        if (!channelDoc.exists) {
          console
              .error("No channel data found for channelId: ", channelId);
          return;
        }
        console.log("Channel data fetched channelId:", channelId);

        const channelData = channelDoc.data();
        const channelTitleData = channelData && channelData.title;
        const channelTitle = channelTitleData || "Unknown Channel";
        const payload = {
          notification: {
            title: `New Post in ${channelTitle}`,
            body: postData.content ? postData.content : "Sent a photo",
          },
          data: {
            channelId: channelId,
            content: postData.content || "",
          },
        };
        console.log("Notification payload created:", payload);

        const usersSnapshot = await admin.firestore().collection("users")
            .where(`joinedChannels.${channelId}`, "!=", null).get();

        console.log(`Searching for users who joined channelId: ${channelId}`);
        console.log(`Found ${usersSnapshot.size} users joined channel.`);
        const uniqueTokens = new Set();
        const promises = [];
        for (const userDoc of usersSnapshot.docs) {
          const userData = userDoc.data();
          if (!userData.mutedChannels ||
            !userData.mutedChannels.includes(channelId)) {
            if (userData.fcmToken && !uniqueTokens.has(userData.fcmToken)) {
              uniqueTokens.add(userData.fcmToken);
              const message = {
                notification: {
                  title: `New Post in ${channelTitle} - maarifa`,
                  body: postData.content || "Sent a photo",
                },
                data: {
                  channelId: channelId,
                  content: postData.content || "",
                },
                token: userData.fcmToken,
              };

              promises.push(admin.messaging().send(message));
            } else {
              console.log(`No fcmToken found for user ${userDoc.id}.`);
            }
          } else {
            console.log(`User ${userDoc.id} has muted the channel.`);
          }
        }
        const responses = await Promise.allSettled(promises);
        responses.forEach((response, index) => {
          if (response.status === "fulfilled") {
            console.log("Successfully sent message:", response.value);
          } else {
            console.error("Error sending message:", response.reason);
          }
        });

        if (promises.length === 0) {
          console.log("No valid tokens found to send notifications.");
        }
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    });

exports.deleteOldPosts = functions.pubsub
    .schedule("every 120 hours").onRun(async (context) => {
      const firestore = admin.firestore();
      const fifteenDaysAgo = new Date();
      fifteenDaysAgo.setDate(fifteenDaysAgo.getDate() - 15);
      const fifteenDaysAgoTimestamp = admin.firestore
          .Timestamp.fromDate(fifteenDaysAgo);
      const oldPostsSnapshot = await firestore.collectionGroup("posts")
          .where("timestamp", "<", fifteenDaysAgoTimestamp)
          .get();
      const batch = firestore.batch();
      oldPostsSnapshot.forEach((doc) => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      console.log(`Deleted ${oldPostsSnapshot.size} old posts`);
      return null;
    });
