const functions = require("firebase-functions/v1")
const admin = require("firebase-admin")
const path = require("path")

admin.initializeApp()

exports.analyzeArtifact = functions
  .region("us-west1")
  .runWith({ memory: "256MB", timeoutSeconds: 60 })
  .storage.object().onFinalize(async (object) => {
    const filePath = object.name

    if (!filePath.startsWith("raw_images/")) {
      return console.log("Pomijanie akcji")
    }

    const fileName = path.basename(filePath)
    const sizeBytes = parseInt(object.size, 10)

    const md5Hash = object.md5Hash
    const md5Hex = Buffer.from(md5Hash, 'base64').toString('hex')

    console.log(`Plik ${fileName} został przesłany. Rozmiar: ${sizeBytes}, MD5: ${md5Hex}`)

    const firestore = admin.firestore()
    const artifactsRef = firestore.collection("artifacts")

    const MAX_RETRIES = 3
    const DELAY_MS = 2000

    for (let i = 0; i < MAX_RETRIES; i++) {
      const snapshot = await artifactsRef.where("storagePath", "==", filePath).get()

      if (!snapshot.empty) {
        const doc = snapshot.docs[0];
        await doc.ref.update({
          metadata: {
            checksum: md5Hex,
            sizeBytes: sizeBytes,
            status: "verified"
          }
        });
        return
      }

      console.log(`Nie znaleziono dokumentu dla ${filePath}. Ponawianie nr.: ${i + 1}/${MAX_RETRIES}...`)
      await new Promise(resolve => setTimeout(resolve, DELAY_MS))
    }

    console.error(`Nie znaleziono dokumentu dla ${filePath} po ${MAX_RETRIES} próbach.`)
  })


exports.onTitleUpdate = functions.firestore.document("artifacts/{title}").onUpdate(async (change) => {
    const messages = [];
    messages.push({notification: { title: 'Title Updated!', body: `${change.before.data().title} => ${change.after.data().title}` },
  topic: "all",
});
    await admin.messaging().send(messages);
});