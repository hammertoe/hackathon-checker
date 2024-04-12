#!/bin/bash

verbose=0
tags=""
ecosystem=""

# Process options
while getopts ":v" opt; do
  case ${opt} in
    v )
      verbose=1  # Set verbose mode
      ;;
    \? )
      echo "Invalid option: $OPTARG" >&2
      exit 1
      ;;
  esac
done

# Shift off the options and optional --
shift $((OPTIND -1))

# Check for the presence of a positional argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 [-v] [github repository]"
    exit 1
fi

# Extract the repository name from the url
repo_name=$(basename "$1" .git)

#echo "making temp dir"
# Make the temp directory to work in
tempprefix=$(basename $0)
tempdir=$(mktemp -d -q)
#tempdir=$(mktemp -d -q /tmp/"${tempprefix}".XXXXXX)

# Clone the git repo
cd "$tempdir"
if [[ "$verbose" -eq 1 ]]; then
    echo "working directory: `pwd`"
fi
    
url="${1}/tarball/HEAD"
if [[ "$verbose" -eq 1 ]]; then
    echo "fetching repo from: ${url}"
fi
curl -LkSs "${url}"  | tar -xzf -

# Check over the files and look for interesting aspects

#echo "starting check"
# Find all files, excluding node_modules
all_files=$(find . \( -type d -name "node_modules" -prune \) -o -type f -print)

# Find all Solidity files
sol_files=$(echo "$all_files" | egrep "\.sol$")
if [ -n "$sol_files" ]; then
    tags="${tags} solidity"
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "solidity files:"
	echo "$sol_files"
    fi
fi

# Find all JS files
js_files=$(echo "$all_files" | egrep "\.(js|ts)$")
if [ -n "$js_files" ]; then
    tags="${tags} javascript"
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "js files:"
	echo "$js_files"
    fi
fi

# Find all Hardhat config files
hh_files=$(echo "$js_files" | grep "hardhat.config.")
if [ -n "$hh_files" ]; then
    tags="${tags} hardhat"
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "hardhat files:"
	echo "$sol_files"
    fi
fi

# Search for usage of the filecoin solidity library
fs_usage=$(echo "$sol_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep 'import.*\(MarketAPI\|DataCapAPI\|MinerAPI\|SendAPI\|VerifRegAPI\|PowerAPI\)' "{}")
if [ -n "$fs_usage" ]; then
    tags="${tags} filecoin-sol"
    ecosystem="${ecosystem} filecoin"
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "usage of filecoin.sol:"
	echo "$fs_usage"
    fi
fi

# Search for usage of the hyperspace endpoint
hs_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep '\(https://filecoin-hyperspace.chainstacklabs.com/rpc/v1\|https://api.hyperspace.node.glif.io/rpc/v1\)' "{}")
if [ -n "$hs_usage" ]; then
    tags="${tags} hyperspace"
    ecosystem="${ecosystem} filecoin fvm"    
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "usage of hyperspace endpoint:"
	echo "$hs_usage"
    fi
fi

# Search for usage of the calibration endpoint
cal_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep '\(https://api.calibration.node.glif.io/rpc/v1\|https://filecoin-calibration.chainup.net/rpc/v1\|https://rpc.ankr.com/filecoin_testnet\|https://calibration.filfox.info/rpc/v1\)' "{}")
if [ -n "$cal_usage" ]; then
    tags="${tags} calibration"
    ecosystem="${ecosystem} filecoin fvm"    
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "usage of calibration endpoint:"
	echo "$cal_usage"
    fi
fi

# Search for usage of Lighthouse
lh_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep 'lighthouse-web3/sdk' "{}")
if [ -n "$lh_usage" ]; then
  tags="${tags} lighthouse"
  ecosystem="${ecosystem} filecoin ipfs"    
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "usage of Lighthouse:"
	echo "$ls_usage"
    fi
fi

# Search for usage of Web3 Storage
w3_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep 'import.*\(web3-storage/w3up-client\|web3.storage\)' "{}")
if [ -n "$w3_usage" ]; then
    tags="${tags} web3storage"
    ecosystem="${ecosystem} filecoin ipfs"
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "usage of Web3.storage:"
	echo "$w3_usage"
    fi
fi

# Search for usage of NFT Storage
nft_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep 'import.*\(nft.storage\)' "{}")
if [ -n "$nft_usage" ]; then
    tags="${tags} nftstorage"
    ecosystem="${ecosystem} filecoin ipfs"
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "usage of NFT Storage:"
	echo "$nft_usage"
    fi
fi

# Search for usage of CO2 Storage
co2_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep -I 'co2.storage' "{}")
if [ -n "$co2_usage" ]; then
    tags="${tags} co2storage"
    ecosystem="${ecosystem} filecoin ipfs"
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "usage of CO2.storage:"
	echo "$co2_usage"
    fi
fi

# Search for usage of Estuary
estuary_usage=$(echo "$js_files" | tr '\n' '\0' | xargs -P0 -0 -I {} grep -i 'estuary.tech' "{}")
if [ -n "$estuary_usage" ]; then
    tags="${tags} estuary"
    ecosystem="${ecosystem} filecoin ipfs"
    if [[ "$verbose" -eq 1 ]]; then
	echo
	echo "*********************"
	echo "usage of Estuary:"
	echo "$estuary_usage"
    fi
fi

# Print out final list of tags
if [[ "$verbose" -eq 1 ]]; then
    echo
    echo "*********************"
    echo "tags and ecosystem:"
fi
echo ${tags} ${ecosystem} | tr " " "\n" | sort | uniq | tr "\n" " "
echo
