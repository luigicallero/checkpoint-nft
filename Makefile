-include .env

.PHONY: deploy

#deploy :; @forge script script/CheckPointNFT.s.sol:CheckPointNFTScript --account test-wallet --rpc-url ${SEPOLIA_RPC_URL} --etherscan-api-key ${ETHERSCAN_API_KEY} --priority-gas-price 1 --verify --broadcast
deploy :; @forge script script/CheckPointNFT.s.sol:CheckPointNFTScript \
  --account test-wallet --rpc-url ${SHAPE_SEPOLIA_RPC_URL} \
  --priority-gas-price 1 --broadcast
#--rpc-url ${SEPOLIA_RPC_URL} --etherscan-api-key ${ETHERSCAN_API_KEY} --priority-gas-price 1 --verify --broadcast

verify :; @forge verify-contract \
  --rpc-url ${SHAPE_SEPOLIA_RPC_URL} \
  --verifier blockscout \
  --verifier-url 'https://explorer-sepolia.shape.network/api/' \
  ${SHAPE_SEPOLIA_CONTRACT_ADDRESS} \
  src/CheckPointNFT.sol:CheckPointNFT

deploy-prod :; @forge script script/CheckPointNFT.s.sol:CheckPointNFTScript \
  --account test-wallet --rpc-url ${SHAPE_RPC_URL} \
  --priority-gas-price 1 --broadcast

verify-prod :; @forge verify-contract \
  --rpc-url ${SHAPE_RPC_URL} \
  --verifier blockscout \
  --verifier-url 'https://shapescan.xyz/api/' \
  ${SHAPE_CONTRACT_ADDRESS} \
  src/CheckPointNFT.sol:CheckPointNFT

# private-key stored using "cast wallet import --private-key XXXXXXX NEW-ACCOUNT-NAME"

authWorld-prod :; @cast send --account test-wallet --rpc-url ${SHAPE_RPC_URL} ${SHAPE_CONTRACT_ADDRESS} \
  "authorizeWorld(address)" 0xEBD4d0B170DB82b91506c5a6895D70b6a509d976 --priority-gas-price 1

# Usage: make mint CONTRACT_ADDRESS=0x... WORLD_NAME="exampleWorld" LEVEL_NUMBER=1 LEVEL_PERCENTAGE=100 PLAYER_SCORE=1000 HEALTH=100 SOULS=10 WEAPONS='["sword","shield"]' ITEMS='["potion","elixir"]' TIME_PLAYED=3600 KILLS=5 BOOSTERS=2
mint-prod :; @cast send --account test-wallet --rpc-url ${SHAPE_RPC_URL} ${SHAPE_CONTRACT_ADDRESS} \
  "mintCheckpoint(string,uint16,uint8,uint128,uint16,uint16,string[],string[],uint32,uint32,uint16)" \
  "Haunted Bastion" 1 100 120 100 3 '["Basic Gun"]' '[]' 61 12 1 \
  --priority-gas-price 1

mint-prod2 :; @cast send --account test-wallet --rpc-url ${SHAPE_RPC_URL} ${SHAPE_CONTRACT_ADDRESS} \
  "mintCheckpoint(string,uint16,uint8,uint128,uint16,uint16,string[],string[],uint32,uint32,uint16)" \
  "Haunted Bastion" 8 100 4500 8 3 '["Basic Gun"]' '[]' 61 200 1 \
  --priority-gas-price 1
  
# View total supply
balance :; @cast call --rpc-url ${SHAPE_SEPOLIA_RPC_URL} ${SHAPE_SEPOLIA_CONTRACT_ADDRESS} \
  "balanceOf(address)" "0xEBd4d0B170DB82b91506c5a6895D70b6a509d976"

# View token URI (Usage: make uri TOKEN_ID=1)
uri :; @cast call --rpc-url ${SHAPE_SEPOLIA_RPC_URL} ${SHAPE_SEPOLIA_CONTRACT_ADDRESS} "tokenURI(uint256)" $(TOKEN_ID)