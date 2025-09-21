// Script pour mettre à jour la configuration Firebase
// Remplacez les valeurs ci-dessous par celles de votre console Firebase

const Map<String, String> firebaseConfig = {
  // Remplacez ces valeurs par celles de votre console Firebase
  'apiKey': 'AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // Votre vraie API Key
  'webAppId': '1:123456789012:web:abcdefghijklmnop', // App ID pour Web
  'androidAppId': '1:123456789012:android:abcdefghijklmnop', // App ID pour Android
  'messagingSenderId': '123456789012', // Votre vrai Sender ID
  'projectId': 'app-perte', // Déjà correct
  'authDomain': 'app-perte.firebaseapp.com', // Déjà correct
  'storageBucket': 'app-perte.appspot.com', // Déjà correct
};

/*
INSTRUCTIONS :

1. Allez sur https://console.firebase.google.com/
2. Sélectionnez votre projet "app-perte"
3. Paramètres du projet → Général → Vos applications
4. Ajoutez une app web et une app Android
5. Copiez les valeurs de configuration
6. Remplacez les valeurs ci-dessus
7. Exécutez ce script pour mettre à jour firebase_options.dart

VALEURS À RÉCUPÉRER :
- apiKey : Clé API Firebase
- webAppId : ID de l'application web
- androidAppId : ID de l'application Android  
- messagingSenderId : ID de l'expéditeur de messages
*/
