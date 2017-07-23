# PKI management

Setting up a PKI is quite easy, and the relevant steps have been simplified for this Docker orchestration:

1. Setting up an own Root CA
2. Generating server certificates
3. Generating client certificates

## Setting up an own Root CA

The setup of an own Root CA is implemented by a small helper script ```bootstrap.sh``` which performs the following
tasks:

- Generating a 4096 bit private key (protected by a passphrase that you have to enter)
- Creation of a self-signed certificate with a validity of 10 years

> Notice: when setting up a Root CA for your production environment, it is recommended to keep the private key
> of the CA on a disconnected machine (i.e. offline), and distribute the issued certificates manually from there. If
> you need automated issuance of certificate, use an intermediate authority. 

Once the script is completed, you'll find the private key of the CA at ```keys/ca.key.pem``` and the self-signed
certificate at ```certificates/completed/ca.cert.pem```.

> If you want to use different defaults for the certificate attributes, simply edit the file ```openssl.cnf```.

### Example
```
$ ./bootstrap.sh
Step 1: Generating 4096-bit private key for the Root CA...
-----------------------------------------------------------------------------
Generating RSA private key, 4096 bit long modulus
.......................................................................................................................++
....++
e is 65537 (0x10001)
Enter pass phrase for keys/ca.key.pem:
Verifying - Enter pass phrase for keys/ca.key.pem:

Step 2: Creating self-signed certificate for the Root CA...
-----------------------------------------------------------------------------
Enter pass phrase for keys/ca.key.pem:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [CH]:
State or Province Name [Lucerne]:
Locality Name [Lucerne]:
Organization Name [Example.com]:
Organizational Unit Name []:
Common Name []:
Email Address [administration@example.com]:
```

## Generating server certificates

A server certificate for a specific domain name can be generated using the little helper ```mkcert-server.sh```. 
The script generates:

- private keys (protected with a pass-phrase) at ```keys/DOMAINNAME.key.pem``` (or ```keys/DOMAINNAME.key.p8```)
- corresponding certificate at ```certificates/completed/DOMAINNAME.cert.pem```.

### Example
```
$ ./mkcert-server.sh logstash.example.com
Generating server certificate for domain 'logstash.example.com' and validity of 2 years...
--> Step 1: generating private key with 2048 bit length
Generating RSA private key, 2048 bit long modulus
..............................+++
........+++
e is 65537 (0x10001)
Enter pass phrase for keys/logstash.example.com.key.pem:
Verifying - Enter pass phrase for keys/logstash.example.com.key.pem:
--> Step 2: converting private key to pk8 format
Enter pass phrase for keys/logstash.example.com.key.pem:
Enter Encryption Password:
Verifying - Enter Encryption Password:
--> Step 3: creating signing request
Enter pass phrase for keys/logstash.example.com.key.pem:
--> Step 4: signing request with private key from CA
Using configuration from ./openssl.cnf
Enter pass phrase for ./keys/ca.key.pem:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 4096 (0x1000)
        Validity
            Not Before: Jul 23 09:38:43 2017 GMT
            Not After : Aug  2 09:38:43 2019 GMT
        Subject:
            commonName                = logstash.example.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Cert Type: 
                SSL Server
            Netscape Comment: 
                OpenSSL Generated Server Certificate
            X509v3 Subject Key Identifier: 
                1B:B7:4B:61:74:E5:C7:90:86:D0:58:CD:1A:7F:06:45:82:D9:B5:64
            X509v3 Authority Key Identifier: 
                keyid:38:16:80:7C:DA:AA:6B:81:C9:66:1A:A9:1A:CD:12:80:23:36:B3:08
                DirName:/C=CH/ST=Lucerne/L=Lucerne/O=Example.com/emailAddress=administration@example.com
                serial:80:D9:80:8C:A5:80:82:2F

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
Certificate is to be certified until Aug  2 09:38:43 2019 GMT (740 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
Done.
```

## Generating client certificates

A client certificate for a specific common name (domain or email address) can be generated using the little helper 
```mkcert-client.sh```. The script generates:

- private keys (protected with a pass-phrase) at ```keys/COMMONNAME.key.pem``` (or ```keys/COMMONNAME.key.p8```)
- corresponding certificate at ```certificates/completed/COMMONNAME.cert.pem```.

### Example
```
$ ./mkcert-client.sh dev.example.com
  Generating client certificate for common name 'dev.example.com' and validity of 2 years...
  --> Step 1: generating private key with 2048 bit length
  Generating RSA private key, 2048 bit long modulus
  .........................................................................+++
  ..+++
  e is 65537 (0x10001)
  Enter pass phrase for keys/dev.example.com.key.pem:
  Verifying - Enter pass phrase for keys/dev.example.com.key.pem:
  --> Step 2: converting private key to pk8 format
  Enter pass phrase for keys/dev.example.com.key.pem:
  Enter Encryption Password:
  Verifying - Enter Encryption Password:
  chmod: Zugriff auf „keys/dev.example.com.key.p8“ nicht möglich: Datei oder Verzeichnis nicht gefunden
  --> Step 3: creating signing request
  Enter pass phrase for keys/dev.example.com.key.pem:
  --> Step 4: signing request with private key from CA
  Using configuration from ./openssl.cnf
  Enter pass phrase for ./keys/ca.key.pem:
  Check that the request matches the signature
  Signature ok
  Certificate Details:
          Serial Number: 4097 (0x1001)
          Validity
              Not Before: Jul 23 09:39:34 2017 GMT
              Not After : Aug  2 09:39:34 2019 GMT
          Subject:
              commonName                = dev.example.com
          X509v3 extensions:
              X509v3 Basic Constraints: 
                  CA:FALSE
              Netscape Cert Type: 
                  SSL Client
              Netscape Comment: 
                  OpenSSL Generated Client Certificate
              X509v3 Subject Key Identifier: 
                  75:0F:95:45:FB:77:3A:C2:30:11:7B:48:00:76:AE:8A:B2:58:8B:83
              X509v3 Authority Key Identifier: 
                  keyid:38:16:80:7C:DA:AA:6B:81:C9:66:1A:A9:1A:CD:12:80:23:36:B3:08
  
              X509v3 Key Usage: critical
                  Digital Signature, Key Encipherment
              X509v3 Extended Key Usage: 
                  TLS Web Client Authentication
  Certificate is to be certified until Aug  2 09:39:34 2019 GMT (740 days)
  Sign the certificate? [y/n]:y
  
  
  1 out of 1 certificate requests certified, commit? [y/n]y
  Write out database with 1 new entries
  Data Base Updated
  Done.
```

## Acknowledgements

A huge thank you goes to [Jamie Nguyen](https://jamielinux.com/). The scripts documented above are heavily influenced 
by https://jamielinux.com/docs/openssl-certificate-authority/index.html