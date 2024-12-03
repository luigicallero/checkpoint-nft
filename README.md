# CheckPoint NFT

A cross-game checkpoint system implemented as an ERC721 NFT, allowing players to carry their progress across different game worlds.

## Overview

CheckPoint NFT is a smart contract system that enables game developers to create interoperable checkpoint tokens that can be used across different game worlds. Each NFT represents a player's achievement or progress point, with metadata containing valuable information that can be interpreted and utilized by other games.

## Features

- **Cross-Game Compatibility**: Checkpoint NFTs can be recognized and utilized across different game worlds
- **Rich Metadata**: Includes detailed checkpoint information such as:
  - World Name
  - Level Number
  - Level Percentage
  - Score
  - Health
  - Shield
  - Weapons
  - Time Played
  - Kills
  - Boosters
- **Authorization System**: Only approved game worlds can mint new checkpoint NFTs
- **OpenSea Compatible**: Follows OpenSea metadata standards for optimal marketplace integration
- **Animated GIF Support**: Displays checkpoint achievements with animated graphics

## Technical Stack

- Solidity ^0.8.13
- OpenZeppelin Contracts
- Foundry Development Framework

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/checkpoint-nft.git
cd checkpoint-nft
```

2. Install dependencies:
```bash
forge install
```

3. Compile contracts:
```bash
forge build
```

## Testing

Run the test suite:
```bash
forge test
```

## Deployment

1. Set up your environment variables:
```bash
cp .env.example .env
# Edit .env with your deployment keys and configuration
```

2. Deploy the contract:
```bash
forge script script/DeployCheckPoint.s.sol --rpc-url <your_rpc_url> --broadcast
```

## Contract Usage

### For Game Developers

1. Get your game world authorized:
```solidity
// Only contract owner can authorize
checkpointNFT.authorizeWorld(gameWorldAddress);
```

2. Mint checkpoint NFTs:
```solidity
checkpointNFT.mintCheckpoint(
    playerAddress,
    "Your World Name",
    levelNumber,
    levelPercentage,
    playerScore,
    difficulty
);
```

### Metadata Structure

```json
{
  "name": "CheckPoint #1",
  "description": "A checkpoint NFT that represents player progress across game worlds",
  "image": "ipfs://QmYourGifHash/checkpoint.gif",
  "attributes": [
    {
      "trait_type": "World Name",
      "value": "Cyber Kingdom"
    },
    {
      "display_type": "number",
      "trait_type": "Level",
      "value": 5
    }
    // ... additional attributes
  ]
}
```

## IPFS Image Guidelines

- Supported format: GIF
- Maximum file size: 100MB
- Recommended dimensions: 350x350 pixels minimum
- Optimization recommended for better performance

## Integration Guide

### For Game Worlds

1. Request authorization from the CheckPoint NFT contract owner
2. Implement checkpoint verification in your game world
3. Define how checkpoint attributes will affect gameplay
4. Set up metadata interpretation for imported checkpoints

### For Marketplaces

The contract follows OpenSea's metadata standards and can be easily integrated with NFT marketplaces.

## Security Considerations

- Only authorized game worlds can mint new checkpoints
- Contract owner can revoke world authorization
- Standard OpenZeppelin security features
- Immutable checkpoint data after minting

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the UNLICENSED License - see the [LICENSE](LICENSE) file for details.

## Contact

Your Name - [@yourusername](https://twitter.com/yourusername)

Project Link: [https://github.com/yourusername/checkpoint-nft](https://github.com/yourusername/checkpoint-nft)

## Acknowledgments

- OpenZeppelin for their secure contract implementations
- OpenSea for their metadata standards
