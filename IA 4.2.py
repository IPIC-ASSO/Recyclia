import tensorflow as tf
import os
import cv2
import numpy as np

# Définition des chemins vers les images
banana_dir = 'C:/Users/IPIC/Desktop/IA/Poubelle verte/bananes'
apple_dir = 'C:/Users/IPIC/Desktop/IA/Poubelle verte/trognon de pomme'

# Chargement des images de bananes
banana_images = []
for filename in os.listdir(banana_dir):
    img = cv2.imread(os.path.join(banana_dir, filename))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, (224, 224))
    banana_images.append(img)

# Chargement des images de trognons de pomme
apple_images = []
for filename in os.listdir(apple_dir):
    img = cv2.imread(os.path.join(apple_dir, filename))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, (224, 224))
    apple_images.append(img)

# Création des labels correspondant aux images
banana_labels = np.ones(len(banana_images))
apple_labels = np.zeros(len(apple_images))

# Concaténation des données et labels
X = np.concatenate((banana_images, apple_images))
y = np.concatenate((banana_labels, apple_labels))

# Normalisation des images
X = X / 255.0

# Définition du modèle
model = tf.keras.Sequential([
    tf.keras.layers.Conv2D(32, (3,3), activation='relu', input_shape=(224,224,3)),
    tf.keras.layers.MaxPooling2D((2,2)),
    tf.keras.layers.Conv2D(64, (3,3), activation='relu'),
    tf.keras.layers.MaxPooling2D((2,2)),
    tf.keras.layers.Conv2D(128, (3,3), activation='relu'),
    tf.keras.layers.MaxPooling2D((2,2)),
    tf.keras.layers.Flatten(),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dense(1, activation='sigmoid')
])

# Compilation du modèle
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Entrainement du modèle
model.fit(X, y, epochs=10, batch_size=32)

# Chargement de l'image de test
test_img = cv2.imread('C:/Users/IPIC/Desktop/IA/image_test.jpg')
test_img = cv2.cvtColor(test_img, cv2.COLOR_BGR2RGB)
test_img = cv2.resize(test_img, (224, 224))
test_img = test_img.reshape(1,224,224,3)

# Prédiction de l'image de test
prediction = model.predict(test_img)[0]

if prediction > 0.5:
    print("C'est une banane!")
else:
    print("C'est un trognon de pomme!")
