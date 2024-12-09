// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {CheckPointNFT} from "../src/CheckPointNFT.sol";

contract CheckPointNFTTest is Test {
    CheckPointNFT public nft;
    address public owner;
    address public authorizedWorld;
    address public player;
    string public constant BASE_URI = "ipfs://QmQxYG2QAngFrGt3DRbtZUfGS5rL9B1ztGeZgM42K1Xvqg";
    
    uint16 private constant MAX_WEAPONS_ARRAY_LENGTH = 20;

    function setUp() public {
        owner = makeAddr("owner");
        authorizedWorld = makeAddr("world");
        player = makeAddr("player");
        
        vm.prank(owner);
        nft = new CheckPointNFT(BASE_URI);
        
        vm.prank(owner);
        nft.authorizeWorld(authorizedWorld);
    }

    function test_Authorization() public {
        // Test world authorization
        assertTrue(nft.authorizedWorlds(authorizedWorld));
        
        // Test authorization revocation
        vm.prank(owner);
        nft.revokeWorld(authorizedWorld);
        assertFalse(nft.authorizedWorlds(authorizedWorld));
        
        // Test unauthorized address cannot authorize
        vm.prank(makeAddr("random"));
        vm.expectRevert();
        nft.authorizeWorld(makeAddr("another"));
    }

    function test_MintCheckpoint() public {
        string[] memory weapons = new string[](2);
        weapons[0] = "Sword";
        weapons[1] = "Bow";
        
        string[] memory items = new string[](2);
        items[0] = "Health Potion";
        items[1] = "Mana Potion";

        vm.prank(authorizedWorld);
        uint256 tokenId = nft.mintCheckpoint(
            player,
            "TestWorld",
            1,
            50,
            1000,
            100,
            100,
            weapons,
            items,
            3600,
            10,
            5
        );

        assertEq(nft.ownerOf(tokenId), player);
        
        CheckPointNFT.CheckpointData memory data = nft.getCheckpointData(tokenId);
        assertEq(data.worldName, "TestWorld");
        assertEq(data.levelNumber, 1);
        assertEq(data.levelPercentage, 50);
        assertEq(data.playerScore, 1000);
        assertEq(data.weapons.length, 2);
        assertEq(data.items.length, 2);
    }

    function test_UpdateCheckpoint() public {
        // First mint a checkpoint
        string[] memory weapons = new string[](1);
        weapons[0] = "Sword";
        string[] memory items = new string[](1);
        items[0] = "Potion";

        vm.prank(authorizedWorld);
        uint256 tokenId = nft.mintCheckpoint(
            player,
            "TestWorld",
            1,
            50,
            1000,
            100,
            100,
            weapons,
            items,
            3600,
            10,
            5
        );

        // Update the checkpoint
        string[] memory newWeapons = new string[](2);
        newWeapons[0] = "Sword";
        newWeapons[1] = "Bow";
        
        string[] memory newItems = new string[](2);
        newItems[0] = "Health Potion";
        newItems[1] = "Mana Potion";

        // Test update from authorized world with player as original sender
        vm.startPrank(authorizedWorld, player);  // authorizedWorld is msg.sender, player is tx.origin
        nft.updateCheckpointData(
            tokenId,
            "TestWorld2",
            2,
            75,
            2000,
            200,
            200,
            newWeapons,
            newItems,
            7200,
            20,
            10
        );
        vm.stopPrank();

        CheckPointNFT.CheckpointData memory data = nft.getCheckpointData(tokenId);
        assertEq(data.worldName, "TestWorld2");
        assertEq(data.levelNumber, 2);
        assertEq(data.levelPercentage, 75);
        assertEq(data.playerScore, 2000);
        assertEq(data.weapons.length, 2);
        assertEq(data.items.length, 2);
    }

    function testFail_UnauthorizedMint() public {
        string[] memory weapons = new string[](0);
        string[] memory items = new string[](0);

        vm.prank(makeAddr("unauthorized"));
        nft.mintCheckpoint(
            player,
            "TestWorld",
            1,
            50,
            1000,
            100,
            100,
            weapons,
            items,
            3600,
            10,
            5
        );
    }

    function test_InputValidation() public {
        string[] memory weapons = new string[](MAX_WEAPONS_ARRAY_LENGTH + 1);
        string[] memory items = new string[](1);

        vm.prank(authorizedWorld);
        vm.expectRevert("Too many weapons");
        nft.mintCheckpoint(
            player,
            "TestWorld",
            1,
            50,
            1000,
            100,
            100,
            weapons,
            items,
            3600,
            10,
            5
        );

        // Test other validation cases
        weapons = new string[](1);
        vm.prank(authorizedWorld);
        vm.expectRevert("Level number too high");
        nft.mintCheckpoint(
            player,
            "TestWorld",
            1001, // MAX_LEVEL + 1
            50,
            1000,
            100,
            100,
            weapons,
            items,
            3600,
            10,
            5
        );
    }

    function test_TokenURI() public {
        string[] memory weapons = new string[](1);
        weapons[0] = "Sword";
        string[] memory items = new string[](1);
        items[0] = "Potion";

        vm.prank(authorizedWorld);
        uint256 tokenId = nft.mintCheckpoint(
            player,
            "TestWorld",
            1,
            50,
            1000,
            100,
            100,
            weapons,
            items,
            3600,
            10,
            5
        );

        string memory uri = nft.tokenURI(tokenId);
        assertTrue(bytes(uri).length > 0);
        // Additional assertions can be added to verify the URI format and content
    }

    // Helper function to create a long string for testing max length
    function _createLongString(uint256 length) internal pure returns (string memory) {
        bytes memory result = new bytes(length);
        for(uint i = 0; i < length; i++) {
            result[i] = "a";
        }
        return string(result);
    }
} 