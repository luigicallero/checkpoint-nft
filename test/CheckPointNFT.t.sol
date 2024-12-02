// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {CheckPointNFT} from "../src/CheckPointNFT.sol";

contract CheckPointNFTTest is Test {
    CheckPointNFT public nft;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy the NFT contract with a base URI
        nft = new CheckPointNFT("https://api.example.com/token/");
        
        // Fund test users
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function test_Initialization() public view {
        assertEq(nft.name(), "CheckPoint");
        assertEq(nft.symbol(), "CPT");
    }

    function test_Minting() public {
        // Authorize the test contract to mint
        nft.authorizeWorld(address(this));
        
        // Mint a checkpoint NFT
        uint256 tokenId = nft.mintCheckpoint(
            user1,          // player
            "World 1",      // worldName
            1,             // levelNumber
            100,           // levelPercentage
            1000,          // playerScore
            2             // difficulty
        );
        
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(tokenId), user1);
    }

    function test_TokenURI() public {
        nft.authorizeWorld(address(this));
        uint256 tokenId = nft.mintCheckpoint(
            user1, "World 1", 1, 100, 1000, 2
        );
        
        string memory uri = nft.tokenURI(tokenId);
        assertTrue(bytes(uri).length > 0);
    }

    function testFail_MintToZeroAddress() public {
        nft.authorizeWorld(address(this));
        nft.mintCheckpoint(
            address(0), "World 1", 1, 100, 1000, 2
        );
    }

    function testFail_InvalidTokenURI() public {
        vm.expectRevert("ERC721: invalid token ID");
        nft.tokenURI(999);
    }

    function test_ConsecutiveTokenIds() public {
        nft.authorizeWorld(address(this));
        
        uint256[] memory ids = new uint256[](3);
        for(uint i = 0; i < 3; i++) {
            ids[i] = nft.mintCheckpoint(
                user1, "World 1", i+1, 100, 1000, 2
            );
        }

        assertEq(nft.balanceOf(user1), 3);
        for(uint i = 0; i < 3; i++) {
            assertTrue(nft.ownerOf(ids[i]) == user1);
        }
    }

    function test_Transfer() public {
        nft.authorizeWorld(address(this));
        uint256 tokenId = nft.mintCheckpoint(
            user1, "World 1", 1, 100, 1000, 2
        );

        vm.prank(user1);
        nft.transferFrom(user1, user2, tokenId);

        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
        assertEq(nft.ownerOf(tokenId), user2);
    }

    function testFail_UnauthorizedTransfer() public {
        nft.authorizeWorld(address(this));
        uint256 tokenId = nft.mintCheckpoint(
            user1, "World 1", 1, 100, 1000, 2
        );

        vm.prank(user2);
        nft.transferFrom(user1, user2, tokenId);
    }
} 