<?php
$pubkey = openssl_pkey_get_public(file_get_contents('selfcert.pem'));
$privkey = openssl_pkey_get_private(file_get_contents('privkey.pem'));

$message = 'hello,world';
$cipher_text = NULL;
$plain_text = NULL;

$keys = NULL;
openssl_seal($message, $cipher_text, $keys, array($pubkey));

$file = fopen('wrapped.bin', 'wb');
fwrite($file, $keys[0]);
fclose($file);

$file = fopen('data.bin', 'wb');
fwrite($file, $cipher_text);
fclose($file);
?>
