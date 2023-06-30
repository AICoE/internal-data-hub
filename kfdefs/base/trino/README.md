# Internal Data Hub Trino

## Trino Truststore

The [trino-truststore](trino-truststore.enc.yaml) file is used to configure Trino to
trust various SSL endpoints that it connects to (e.g. PSI Ceph S3).

We occasionally need to add a certificate to the truststore. This section
outlines how to do so.

* Frist, extract the truststore from the sops-encrypted file. Decrypt the
  `trino-truststore.enc.yaml` file (using `sops -d`), then copy the value
  of the `localkeys.jks` item. This is a base64 encoded string. Decode it and
  save the result to a file:

```
echo "$BASE_64_ENCODED_STRING" | base64 -d > localkeys.jks
```

* Run the following command to add the new certificate to the truststore (this
  command assumes the file is stored in a file called `cert.crt`))*Note:
  replace `$SOME_CERT_ALIAS` with a meaningful descriptor for the new
  certificate*

```
keytool -import -alias $SOME_CERT_ALIAS -file cert.crt -trustcacerts -keystore localkeys.jks
```

* Finally, base64 encode the newly updated truststore and update `trino-truststore.enc.yaml`
  with the new value.
