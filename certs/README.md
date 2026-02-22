The first command, mkdir certs, creates a directory in your current path to store your security credentials. The second command uses the OpenSSL tool to generate a self-signed SSL certificate, 
which is necessary for your Nginx server to run on port 443 with HTTPS. Within that command, the req -x509 flag tells the system to create a certificate that is valid immediately, 
while the -nodes flag ensures the private key is created without a passphrase so that Nginx can restart automatically without you having to manually type a password.
You are setting the certificate to remain valid for one year using the -days 365 flag and generating a standard 2048-bit RSA key with the -newkey rsa:2048 flag. 
The -keyout and -out flags designate where to save your private key and your public certificate respectively, creating the files nginx.key and nginx.crt inside your new folder. 
This setup allows you to test secure connections locally, although your browser will display a warning because the certificate is signed by you rather than a trusted certificate authority.

# ------ COMMAND ------ #
mkdir certs
  421  openssl req -x509 -nodes -days 365 -newkey rsa:2048   -keyout certs/nginx.key -out certs/nginx.crt   -subj "/C=IT/ST=Italy/L=Lab/O=Docker/CN=localhost"

