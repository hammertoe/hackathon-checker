# Hackathon checker

This is a simple script to check some basic things for a FVM hackathon.
By default it returns a list of tags of Filecoin-related tech used.

To run it:

`sh checker.sh <github_url>`

e.g.

```% sh checker.sh https://github.com/sandrotbilisi/decademic
filecoin ipfs javascript solidity web3storage
```

It also has a verbose mode that can give you some information to check:

`sh checker.sh -v <github_url>`


e.g.

```
% sh checker.sh -v https://github.com/sandrotbilisi/decademic
working directory: /var/folders/q7/4j712pfx7995z3g8d37d3pph0000gn/T/tmp.uGW9Z4ZKnT
fetching repo from: https://github.com/sandrotbilisi/decademic/tarball/HEAD

*********************
solidity files:
./sandrotbilisi-decademic-6f7d146/crypto/truffle/contracts/CFAv1Forwarder.sol
./sandrotbilisi-decademic-6f7d146/crypto/truffle/contracts/NFTWithIPFS.sol
./sandrotbilisi-decademic-6f7d146/ZK/verifier.sol

*********************
js files:
./sandrotbilisi-decademic-6f7d146/crypto/truffle/migrations/1_migrationFile.js
./sandrotbilisi-decademic-6f7d146/crypto/truffle/test/1_test_file.js
./sandrotbilisi-decademic-6f7d146/crypto/truffle/truffle-config.js
./sandrotbilisi-decademic-6f7d146/extension/popup.js
./sandrotbilisi-decademic-6f7d146/extension/backround.js
./sandrotbilisi-decademic-6f7d146/extension/decademic-inject.js
./sandrotbilisi-decademic-6f7d146/extension/request.js
./sandrotbilisi-decademic-6f7d146/extension/library.js
./sandrotbilisi-decademic-6f7d146/extension/content-script.js
./sandrotbilisi-decademic-6f7d146/frontend/vite.config.js
./sandrotbilisi-decademic-6f7d146/frontend/src/components/Superfluidinit.js
./sandrotbilisi-decademic-6f7d146/frontend/src/components/cryptoFunctions.js
./sandrotbilisi-decademic-6f7d146/backend/index.js
./sandrotbilisi-decademic-6f7d146/sdk/main.js
./sandrotbilisi-decademic-6f7d146/keycert/keycert/vite.config.js

*********************
usage of Web3.storage:
          const w3upClientModule = await import("@web3-storage/w3up-client");

*********************
tags and ecosystem:
filecoin ipfs javascript solidity web3storage 
```


It is also deployed on IBM Cloud a function at:

`https://hackathon-checker.1fj4a2y44fxx.us-east.codeengine.appdomain.cloud/checker`

So can be called from `curl`, especially
useful when you are at a hackathon judging with limited bandwidth and don't want to download
the entire codebase locally. It starts and scales up on demand, so first run may be slow.

e.g.

```% curl "https://hackathon-checker.1fj4a2y44fxx.us-east.codeengine.appdomain.cloud/checker?format=csv&url=https://github.com/peeranha/peeranha"
hardhat,javascript,solidity
```
