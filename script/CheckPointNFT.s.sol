// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {CheckPointNFT} from "../src/CheckPointNFT.sol";
import {console} from "forge-std/console.sol";

contract CheckPointNFTScript is Script {
    string constant BASE_IMAGE_URI = "ipfs://QmYveRKKGN4KSeXudM1fW1rnAzKcjQvKgP9xbEsP44vxph";

    function setUp() public {}

    function run() public returns (CheckPointNFT) {
        vm.startBroadcast();
        
        // Deploy the NFT contract
        CheckPointNFT nft = new CheckPointNFT(BASE_IMAGE_URI);
        
        // Log the deployment
        console.log("CheckPointNFT deployed to:", address(nft));
        
        vm.stopBroadcast();
        
        return nft;
    }
} 