# Quelltexte zum TLS Workshop

Generating Client/Server certificates with a local CA

Attention: make sure the common names in the created certs are different from each other (otherwise it will be detected).


1. Generate a CA

   - openssl genrsa -des3 -out ca.key 4096                                        (create key)
     
     used password: test
     
   - openssl req -new -key ca.key -sha256  -out ca.csr                            (create cert signing request)
     (use e.g. "root" for common name)
     (no challenge password needed)
     
   - openssl x509 -req -days 365 -in ca.csr -signkey ca.key -sha256 -out ca.pem   (generate self signed certificate)
   
   - openssl x509 -in ca.pem -text                                                 (print details)
   
   
   
   Attention: this does not work:
   
   - openssl req -x509 -newkey rsa:4096 -keyout cakey.pem -out ca.pem     (creation)
     (use e.g. "root" for common name)

      Used PW: test
   
   
   
2. Generate server certificate/key pair
        (no password required)
        
   - openssl genrsa -out server.key 1024                       (generate key)

   - openssl req -key server.key -new -out server.req          (create cert request)
     * use e.g. "server" as common name
     * a challenge password is not needed


3. create server certificate

   - echo "00" > file.srl         (CA needs a different serial number for each signed certificate)
   
   - openssl x509 -req -in server.req -CA ca.pem -CAkey ca.key -CAserial file.srl -out server.pem   (create server cert)

   
   
4. Generate client certificate/key pair

   - Either choose to encrypt the key(a) or not(b)
        a. Encrypt the client key with a passphrase
            openssl genrsa -des3 -out client.key 1024
        b. Don't encrypt the client key
            openssl genrsa -out client.key 1024

      Used: option b

   - openssl req -key client.key -new -out client.req           (create cert request)
     * use e.g. "client" as common name
     * a challenge password is not needed
     
   - echo "01" > file.srl                                       (update counter to get a new serial number)
   
   - openssl x509 -req -in client.req -CA ca.pem -CAkey ca.key -CAserial file.srl -out client.pem   (create client cert)



5. Verify certificates
   
   - openssl verify -verbose -x509_strict -CAfile ca.pem ca.pem
   - openssl verify -verbose -x509_strict -CAfile ca.pem server.pem
   - openssl verify -verbose -x509_strict -CAfile ca.pem client.pem
   
   
   
