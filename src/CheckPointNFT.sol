// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CheckPointNFT is ERC721, Ownable {
    using Strings for uint256;
    
    event CheckpointUpdated(uint256 indexed tokenId, address indexed updater);
    
    uint256 private _nextTokenId;
    string private _baseTokenURI;

    // Update struct to store checkpoint data
    struct CheckpointData {
        string worldName;
        uint256 levelNumber;
        uint256 levelPercentage;
        uint256 playerScore;
        uint256 health;
        uint256 shield;
        string[] weapons;
        string[] items;
        uint256 timePlayed;
        uint256 kills;
        uint256 boosters;
    }

    // Mapping from token ID to checkpoint data
    mapping(uint256 => CheckpointData) public checkpoints;
    mapping(address => bool) public authorizedWorlds;

    // eentrancy guard
    bool private _locked;
    modifier nonReentrant() {
        require(!_locked, "ReentrancyGuard: reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    // Input validation constants
    uint256 private constant MAX_WEAPONS_ARRAY_LENGTH = 20;  // Maximum items in weapons arrays
    uint256 private constant MAX_ITEMS_ARRAY_LENGTH = 1000;  // Maximum items in items arrays
    uint256 private constant MAX_BOOSTERS = 1000;  // Maximum boosters arrays
    uint256 private constant MAX_STRING_LENGTH = 100; // Maximum characters in strings
    uint256 private constant MAX_HEALTH = 10000;
    uint256 private constant MAX_SHIELD = 10000;
    uint256 private constant MAX_LEVEL = 1000;

    constructor(string memory baseTokenURI) ERC721("CheckPoint", "CPT") Ownable(msg.sender) {
        _baseTokenURI = baseTokenURI;
    }

    function authorizeWorld(address worldAddress) external onlyOwner {
        authorizedWorlds[worldAddress] = true;
    }

    function revokeWorld(address worldAddress) external onlyOwner {
        authorizedWorlds[worldAddress] = false;
    }

    function mintCheckpoint(
        address player,
        string memory worldName,
        uint256 levelNumber,
        uint256 levelPercentage,
        uint256 playerScore,
        uint256 health,
        uint256 shield,
        string[] memory weapons,
        string[] memory items,
        uint256 timePlayed,
        uint256 kills,
        uint256 boosters
    ) external returns (uint256) {
        require(authorizedWorlds[msg.sender], "Only authorized worlds can mint checkpoints");
        
        uint256 tokenId = _nextTokenId++;
        _safeMint(player, tokenId);
        
        checkpoints[tokenId] = CheckpointData({
            worldName: worldName,
            levelNumber: levelNumber,
            levelPercentage: levelPercentage,
            playerScore: playerScore,
            health: health,
            shield: shield,
            weapons: weapons,
            items: items,
            timePlayed: timePlayed,
            kills: kills,
            boosters: boosters
        });

        return tokenId;
    }

    function getCheckpointData(uint256 tokenId) external view returns (CheckpointData memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return checkpoints[tokenId];
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        CheckpointData memory checkpoint = checkpoints[tokenId];
        
        return string(abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(bytes(abi.encodePacked(
                '{"name": "Checkpoint #', 
                tokenId.toString(),
                '", "description": "Game checkpoint in ', 
                checkpoint.worldName,
                '", "image": "', 
                _baseURI(),  // Use the base URI for image
                '", "attributes": [',
                    '{"trait_type": "Level", "value": ', checkpoint.levelNumber.toString(), '},',
                    '{"trait_type": "Progress", "value": ', checkpoint.levelPercentage.toString(), '},',
                    '{"trait_type": "Score", "value": ', checkpoint.playerScore.toString(), '},',
                    '{"trait_type": "Health", "value": ', checkpoint.health.toString(), '},',
                    '{"trait_type": "Shield", "value": ', checkpoint.shield.toString(), '},',
                    '{"trait_type": "Time Played", "value": ', checkpoint.timePlayed.toString(), '},',
                    '{"trait_type": "Kills", "value": ', checkpoint.kills.toString(), '}',
                ']}'
            )))
        ));
    }

    function updateCheckpointData(
        uint256 tokenId,
        string memory worldName,
        uint256 levelNumber,
        uint256 levelPercentage,
        uint256 playerScore,
        uint256 health,
        uint256 shield,
        string[] memory weapons,
        string[] memory items,
        uint256 timePlayed,
        uint256 kills,
        uint256 boosters
    ) external nonReentrant {
        require(authorizedWorlds[msg.sender], "Only authorized worlds can update checkpoints");
        require(tx.origin == ownerOf(tokenId), "Transaction must be initiated by token owner");
        
        // Input validation
        require(bytes(worldName).length <= MAX_STRING_LENGTH, "World name too long");
        require(levelNumber <= MAX_LEVEL, "Level number too high");
        require(levelPercentage <= 100, "Invalid level percentage");
        require(health <= MAX_HEALTH, "Health value too high");
        require(shield <= MAX_SHIELD, "Shield value too high");
        require(weapons.length <= MAX_WEAPONS_ARRAY_LENGTH, "Too many weapons");
        require(items.length <= MAX_ITEMS_ARRAY_LENGTH, "Too many items");
        require(boosters <= MAX_BOOSTERS, "Too many boosters");

        // Validate array contents
        for(uint i = 0; i < weapons.length; i++) {
            require(bytes(weapons[i]).length <= MAX_STRING_LENGTH, "Weapon name too long");
        }
        for(uint i = 0; i < items.length; i++) {
            require(bytes(items[i]).length <= MAX_STRING_LENGTH, "Item name too long");
        }
        
        checkpoints[tokenId] = CheckpointData({
            worldName: worldName,
            levelNumber: levelNumber,
            levelPercentage: levelPercentage,
            playerScore: playerScore,
            health: health,
            shield: shield,
            weapons: weapons,
            items: items,
            timePlayed: timePlayed,
            kills: kills,
            boosters: boosters
        });

        emit CheckpointUpdated(tokenId, msg.sender);
    }
}
