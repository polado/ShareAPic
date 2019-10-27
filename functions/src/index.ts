import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { log } from 'util';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const sendToTopic = functions.firestore
    .document('images/{imageID}')
    .onWrite(async snapshot => {
        const image = snapshot.after.data();

        log(`image added`);
        if (image) {
            log(`image ${image}`);
            var senderName: string = '', senderPhoto: string = '';
            await db.collection('users').doc(image.user).get().then(
                async snapshot => {
                    senderName = snapshot.get('name');
                    senderPhoto = snapshot.get('photo_url');

                    log(`image user ${snapshot}`);
                }
            );
            const payload: admin.messaging.MessagingPayload = {
                notification: {
                    title: 'New Pic!',
                    body: `${senderName} added a new picture`,
                    icon: `${senderPhoto}`,
                    click_action: 'FLUTTER_NOTIFICATION_CLICK'
                }
            };

            log(`image send`);
            return fcm.sendToTopic('images', payload);
        }
        else return null;
    });