// Node.js e.g via a Firebase Cloud Function

const admin = require("firebase-admin");

const serviceAccount = require("./server-key/notification-topic-firebase-adminsdk.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});


const message = {
    "data": {
        "title": "From topic",
        "body": "Hello this content from Topic"
    },
    "notification": {
        "title": "From topic",
        "body": "Hello this content from Topic"
    },
    topic: "Grade-12A",
};

admin
    .messaging()
    .send(message)
    .then((response) => {
        console.log("Successfully sent message:", response);
    })
    .catch((error) => {
        console.log("Error sending message:", error);
    });