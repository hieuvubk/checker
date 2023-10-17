#!/bin/bash

KEY="test"
CHAINID="testnet-1"
KEYRING="test"
MONIKER="localtestnet"
KEYALGO="secp256k1"
LOGLEVEL="info"

# retrieve all args
WILL_RECOVER=0
WILL_INSTALL=0
WILL_CONTINUE=0
# $# is to check number of arguments
if [ $# -gt 0 ];
then
    # $@ is for getting list of arguments
    for arg in "$@"; do
        case $arg in
        --recover)
            WILL_RECOVER=1
            shift
            ;;
        --install)
            WILL_INSTALL=1
            shift
            ;;
        --continue)
            WILL_CONTINUE=1
            shift
            ;;
        *)
            printf >&2 "wrong argument somewhere"; exit 1;
            ;;
        esac
    done
fi

# continue running if everything is configured
if [ $WILL_CONTINUE -eq 1 ];
then
    # Start the node (remove the --pruning=nothing flag if historical queries are not needed)
    checkerd start --pruning=nothing --log_level $LOGLEVEL --minimum-gas-prices=0.0001uan1
    exit 1;
fi

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# install checkerd if not exist
if [ $WILL_INSTALL -eq 0 ];
then 
    command -v checkerd > /dev/null 2>&1 || { echo >&1 "installing checkerd"; make install; }
else
    echo >&1 "installing checkerd"
    rm -rf $HOME/.checker*
    make install
fi

checkerd config keyring-backend $KEYRING
checkerd config chain-id $CHAINID

# determine if user wants to recorver or create new
if [ $WILL_RECOVER -eq 0 ];
then
    checkerd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO
else
    checkerd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO --recover
fi

echo >&1 "\n"

# init chain
checkerd init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to uan1
cat $HOME/.checker/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="uan1"' > $HOME/.checker/config/tmp_genesis.json && mv $HOME/.checker/config/tmp_genesis.json $HOME/.checker/config/genesis.json
cat $HOME/.checker/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="uan1"' > $HOME/.checker/config/tmp_genesis.json && mv $HOME/.checker/config/tmp_genesis.json $HOME/.checker/config/genesis.json
cat $HOME/.checker/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="uan1"' > $HOME/.checker/config/tmp_genesis.json && mv $HOME/.checker/config/tmp_genesis.json $HOME/.checker/config/genesis.json
cat $HOME/.checker/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="uan1"' > $HOME/.checker/config/tmp_genesis.json && mv $HOME/.checker/config/tmp_genesis.json $HOME/.checker/config/genesis.json

# Set gas limit in genesis
# cat $HOME/.checker/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="10000000"' > $HOME/.checker/config/tmp_genesis.json && mv $HOME/.checker/config/tmp_genesis.json $HOME/.checker/config/genesis.json

# Allocate genesis accounts (cosmos formatted addresses)
checkerd add-genesis-account $KEY 1000000000000uan1 --keyring-backend $KEYRING

# Sign genesis transaction
checkerd gentx $KEY 1000000uan1 --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
checkerd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
checkerd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
checkerd start --pruning=nothing --log_level $LOGLEVEL