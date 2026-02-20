# Usa l'immagine base di Nginx
FROM nginx:latest

# Copia il TUO file di configurazione dentro l'immagine
# Questo rende l'immagine "auto-consistente" e più sicura
COPY nginx.conf /etc/nginx/nginx.conf

# Esponi la porta 80
EXPOSE 80
