#!/bin/bash

uname -a
echo $PATH
which git
ls /usr/bin
ls /bin
ls /usr/sbin
ls /sbin


exit

if [ $# -eq 0 ]; then
  echo "Usage: $0 [github repository]"
  exit 0
fi

# Start with empty list of tags
tags=""

# Extract the repository name from the url
repo_name=$(basename "$1" .git)

echo "making temp dir"
# Make the temp directory to work in
tempprefix=$(basename $0)
tempdir=$(mktemp -d -q)
#tempdir=$(mktemp -d -q /tmp/"${tempprefix}".XXXXXX)

echo "fetching repo"
# Clone the git repo
cd "$tempdir"
echo "fetching: ${1}/archive/refs/heads/main.tar.gz"


# Define a temporary file for the archive.
temp_archive=$(mktemp)

# Fetch the URL. If curl fails, report the error and exit.
if ! curl -LkSs -o "${temp_archive}" "${1}/archive/refs/heads/main.tar.gz"; then
    echo "Error: Failed to fetch the URL." >&2
    rm -f "${temp_archive}"  # Clean up temporary file
    exit 1
fi

# Unpack the archive. If tar fails, report the error and exit.
if ! tar -xzf "${temp_archive}"; then
    echo "Error: Failed to unpack the archive." >&2
    rm -f "${temp_archive}"  # Clean up temporary file
    exit 1
fi

#curl -LkSs "${1}/archive/refs/heads/main.tar.gz"  | tar -xzf -
## ${PIPESTATUS[0]} contains the exit status of the 'curl' command.
## ${PIPESTATUS[1]} contains the exit status of the 'tar' command.
#if [ "${PIPESTATUS[0]}" != "0" ]; then
#    echo "Error: Failed to fetch the URL." >&2
#    exit 1
#elif [ "${PIPESTATUS[1]}" != "0" ]; then
#    echo "Error: Failed to unpack the archive." >&2
#    exit 1
#fi

# Check over the files and look for interesting aspects
cd "${repo_name}-main"
echo "changing dir"
pwd
ls

echo "starting check"
# Find all files, excluding node_modules
all_files=$(find . \( -type d -name "node_modules" -prune \) -o -type f -print)

# Find all Solidity files
sol_files=$(echo "$all_files" | egrep "\.sol$")
if [ -n "$sol_files" ]; then
  tags="${tags} solidity"
fi

# Find all JS files
js_files=$(echo "$all_files" | egrep "\.(js|ts)$")
if [ -n "$js_files" ]; then
  tags="${tags} javascript"
fi

# Find all Hardhat config files
hh_files=$(echo "$js_files" | grep "hardhat.config.")
if [ -n "$hh_files" ]; then
  tags="${tags} hardhat"
fi

# Search for usage of the filecoin solidity library
fs_usage=$(echo "$sol_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep 'import.*\(MarketAPI\|DataCapAPI\|MinerAPI\|SendAPI\|VerifRegAPI\|PowerAPI\)' "{}")
if [ -n "$fs_usage" ]; then
  tags="${tags} filecoin-sol"
fi

# Search for usage of the hyperspace endpoint
hs_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep '\(https://filecoin-hyperspace.chainstacklabs.com/rpc/v1\|https://api.hyperspace.node.glif.io/rpc/v1\)' "{}")
if [ -n "$hs_usage" ]; then
  tags="${tags} hyperspace"
fi

# Search for usage of the calibration endpoint
cal_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep '\(https://api.calibration.node.glif.io/rpc/v1\|https://filecoin-calibration.chainup.net/rpc/v1\|https://rpc.ankr.com/filecoin_testnet\|https://calibration.filfox.info/rpc/v1\)' "{}")
if [ -n "$cal_usage" ]; then
  tags="${tags} calibration"
fi

# Search for usage of Lighthouse
lh_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep 'lighthouse-web3/sdk' "{}")
if [ -n "$lh_usage" ]; then
  tags="${tags} lighthouse"
fi

# Search for usage of Web3 Storage
w3_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep 'import.*\(web3-storage/w3up-client\|web3.storage\)' "{}")
if [ -n "$w3_usage" ]; then
  tags="${tags} web3storage"
fi

# Search for usage of NFT Storage
nft_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep 'import.*\(nft.storage\)' "{}")
if [ -n "$nft_usage" ]; then
  tags="${tags} nftstorage"
fi
# Print out final list of tags
echo ${tags}
