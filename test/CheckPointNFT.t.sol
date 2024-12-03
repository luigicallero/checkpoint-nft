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

    function _mintHelper(address to, string memory world, uint256 level) internal returns (uint256) {
        string[] memory weapons = new string[](0);
        string[] memory boosters = new string[](0);
        return nft.mintCheckpoint(
            to,             // player
            world,         // worldName
            level,         // levelNumber
            100,           // levelPercentage
            1000,          // playerScore
            100,           // health
            50,            // shield
            weapons,       // weapons array
            3600,          // timePlayed
            5,             // kills
            boosters       // boosters array
        );
    }

    function test_Initialization() public view {
        assertEq(nft.name(), "CheckPoint");
        assertEq(nft.symbol(), "CPT");
    }

    function test_Minting() public {
        nft.authorizeWorld(address(this));
        
        uint256 tokenId = _mintHelper(user1, "World 1", 1);
        
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(tokenId), user1);
    }

    function test_TokenURI() public {
        nft.authorizeWorld(address(this));
        uint256 tokenId = _mintHelper(user1, "World 1", 1);
        string memory uri = nft.tokenURI(tokenId);
        assertTrue(bytes(uri).length > 0);
    }

    function testFail_MintToZeroAddress() public {
        nft.authorizeWorld(address(this));
        _mintHelper(address(0), "World 1", 1);
    }

    function testFail_InvalidTokenURI() public {
        vm.expectRevert("ERC721: invalid token ID");
        nft.tokenURI(999);
    }

    function test_ConsecutiveTokenIds() public {
        nft.authorizeWorld(address(this));
        
        uint256[] memory ids = new uint256[](3);
        for(uint i = 0; i < 3; i++) {
            ids[i] = _mintHelper(user1, "World 1", i+1);
        }

        assertEq(nft.balanceOf(user1), 3);
        for(uint i = 0; i < 3; i++) {
            assertTrue(nft.ownerOf(ids[i]) == user1);
        }
    }

    function test_Transfer() public {
        nft.authorizeWorld(address(this));
        uint256 tokenId = _mintHelper(user1, "World 1", 1);

        vm.prank(user1);
        nft.transferFrom(user1, user2, tokenId);

        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
        assertEq(nft.ownerOf(tokenId), user2);
    }

    function testFail_UnauthorizedTransfer() public {
        nft.authorizeWorld(address(this));
        _mintHelper(user1, "World 1", 1);

        vm.prank(user2);
        nft.transferFrom(user1, user2, 1);
    }
} 