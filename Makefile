-include .env

.PHONY: deploy

#deploy :; @forge script script/CheckPointNFT.s.sol:CheckPointNFTScript --account test-wallet --rpc-url ${SEPOLIA_RPC_URL} --etherscan-api-key ${ETHERSCAN_API_KEY} --priority-gas-price 1 --verify --broadcast
deploy :; @forge script script/CheckPointNFT.s.sol:CheckPointNFTScript --account test-wallet --rpc-url ${SHAPE_SEPOLIA_RPC_URL} --priority-gas-price 1 --broadcast
#--rpc-url ${SEPOLIA_RPC_URL} --etherscan-api-key ${ETHERSCAN_API_KEY} --priority-gas-price 1 --verify --broadcast

verify :; @forge verify-contract \
  --rpc-url ${SHAPE_SEPOLIA_RPC_URL} \
  --verifier blockscout \
  --verifier-url 'https://explorer-sepolia.shape.network/api/' \
  ${SHAPE_SEPOLIA_CONTRACT_ADDRESS} \
  src/CheckPointNFT.sol:CheckPointNFT

# private-key stored using "cast wallet import --private-key XXXXXXX NEW-ACCOUNT-NAME"

# Usage: make mint CONTRACT_ADDRESS=0x... TO_ADDRESS=0x...
mint :; @cast send --account test-wallet --rpc-url ${SEPOLIA_RPC_URL} ${CONTRACT_ADDRESS} "mint()" --priority-gas-price 1

# View total supply
supply :; @cast call --rpc-url ${SEPOLIA_RPC_URL} ${CONTRACT_ADDRESS} "totalSupply()"

# View token URI (Usage: make uri TOKEN_ID=1)
uri :; @cast call --rpc-url ${SEPOLIA_RPC_URL} ${CONTRACT_ADDRESS} "tokenURI(uint256)" $(TOKEN_ID)