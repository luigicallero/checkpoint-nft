// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CheckPointNFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    string private _baseTokenURI;

    // Struct to store checkpoint data
    struct CheckpointData {
        string worldName;
        uint256 levelNumber;
        uint256 levelPercentage;
        uint256 timestamp;
        uint256 playerScore;
        uint256 difficulty;
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
        uint256 difficulty
    ) external returns (uint256) {
        require(authorizedWorlds[msg.sender], "Only authorized worlds can mint checkpoints");
        
        uint256 tokenId = _nextTokenId++;
        _safeMint(player, tokenId);
        
        checkpoints[tokenId] = CheckpointData({
            worldName: worldName,
            levelNumber: levelNumber,
            levelPercentage: levelPercentage,
            timestamp: block.timestamp,
            playerScore: playerScore,
            difficulty: difficulty
        });

        return tokenId;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }
}
