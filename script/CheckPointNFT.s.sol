// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {CheckPointNFT} from "../src/CheckPointNFT.sol";

contract CheckPointNFTScript is Script {
    string constant BASE_IMAGE_URI = "ipfs://QmQxYG2QAngFrGt3DRbtZUfGS5rL9B1ztGeZgM42K1Xvqg";

    function setUp() public {}

    function run() public returns (CheckPointNFT) {
        vm.startBroadcast();
        
        // Deploy the NFT contract
        CheckPointNFT nft = new CheckPointNFT(BASE_IMAGE_URI);
        
        // Optional: You can add initial setup here, like:
        // nft.authorizeWorld(YOUR_GAME_ADDRESS);
        
        vm.stopBroadcast();
        
        return nft;
    }
} 