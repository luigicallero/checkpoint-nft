// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CheckPointNFT is ERC721, Ownable {
    using Strings for uint256;
    uint256 private _nextTokenId;
    string private _baseTokenURI;

    // Updated struct to store checkpoint data
    struct CheckpointData {
        string worldName;
        uint256 levelNumber;
        uint256 levelPercentage;
        uint256 playerScore;
        uint256 health;
        uint256 shield;
        string[] weapons;
        uint256 timePlayed;
        uint256 kills;
        string[] boosters;
        string imageURI;
    }

    // Mapping from token ID to checkpoint data
    mapping(uint256 => CheckpointData) public checkpoints;
    mapping(address => bool) public authorizedWorlds;

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
        uint256 timePlayed,
        uint256 kills,
        string[] memory boosters,
        string memory imageURI
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
            timePlayed: timePlayed,
            kills: kills,
            boosters: boosters,
            imageURI: imageURI
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

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    function updateCheckpointImage(uint256 tokenId, string memory newImageURI) external {
        require(msg.sender == ownerOf(tokenId), "Only token owner can update image");
        checkpoints[tokenId].imageURI = newImageURI;
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
                checkpoint.imageURI,
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
}
