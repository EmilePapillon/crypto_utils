#!/bin/sh
#generates a rsa-pss private key with 2048 bits and a standard public exponent
genpkey(){
	openssl genpkey -algorithm rsa-pss \
		-pkeyopt rsa_keygen_bits:2048 \
		-pkeyopt rsa_keygen_pubexp:65537 \
		-out $1
}

#extracts the private key from the public key
genpub(){
	openssl rsa -in $1 -pubout -out $2
}

#creates a binary digest with sha256 hashing
hash_dgst(){
	infile=$1
	outfile=$2
	openssl dgst -sha256 -binary -out $outfile $infile
}

#creates a PSS padded signature of a sha256 hash using a private key
rsassa_sign(){
	privkey=$1
	hsh=$2
	openssl pkeyutl -sign -in $hsh \
		-inkey $privkey \
		-out "$(basename $hsh).sig" \
		-pkeyopt digest:sha256 \
		-pkeyopt rsa_padding_mode:pss \
		-pkeyopt rsa_pss_saltlen:-1
}

#verifies a signature with a public key (hash digest needed as input)
rsassa_verif(){
	openssl pkeyutl -verify \
  		-in $1 -sigfile $2 \
  		-pkeyopt rsa_padding_mode:pss \
  		-pubin -inkey $3 \
  		-pkeyopt rsa_pss_saltlen:-1 \
  		-pkeyopt digest:sha256
}

#signs a file taking care of creating the hash digest
sign_file(){
	pk=$1
	if=$2
	rand=$(dd if=/dev/urandom bs=1 count=5 2> /dev/null | sha256sum | cut -c1-6)
	tmp="/tmp/$rand/$if"
	mkdir -p $(dirname $tmp)
	hash_dgst $if $tmp
	rsassa_sign $pk $tmp
	rm -r $tmp
}

#verifies a signature taking care of creating the files hash digest
verif_file(){
	pubk=$1
	if=$2
        sig=$3
        rand=$(dd if=/dev/urandom bs=1 count=5 2> /dev/null | sha256sum | cut -c1-6)
        tmp="/tmp/$rand/$if"
        mkdir -p $(dirname $tmp)
        hash_dgst $if $tmp
	rsassa_verif $tmp $sig $pubk
        rm -r $tmp
}

# website for verif : https://8gwifi.org/RSAFunctionality?rsasignverifyfunctions=rsasignverifyfunctions&keysize=4096
