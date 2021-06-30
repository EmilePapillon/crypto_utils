# crypto_utils

A few tools to create crypto keys, sign and verify a file

## Usage
- Creating a key: `genpkey private.key` -- generates RSASSA key
- Extracting public key: `genpub private.key public.key`
- Signing a file: `sign_file private.key <file>` -- creates a binary signature file named file.sig with PSS padding
- Verifying the signature: `verif_file public.key <file> <signature>`

And Voila!
