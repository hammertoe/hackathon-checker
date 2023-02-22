#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 [github repository]"
  exit 1
fi

# extract the repository name from the url
repo_name=$(basename "$1" .git)

# check if the repository directory exists
if [ ! -d "$repo_name" ]; then
  # clone the repository if it doesn't exist
  git clone "$1"
fi

# navigate to the repository directory
cd "$repo_name"

git pull

echo "Solidity files found:"
find . -type f -name "*.sol"

echo "Files that use the Solidity APIs:"
grep -r 'import.*\(MarketAPI\|DataCapAPI\|MinerAPI\|SendAPI\|VerifRegAPI\|PowerAPI\)'

echo "Occurances of hyperspace RPC endpoint:"
grep -r '\(https://filecoin-hyperspace.chainstacklabs.com/rpc/v1\|https://api.hyperspace.node.glif.io/rpc/v1\)'

