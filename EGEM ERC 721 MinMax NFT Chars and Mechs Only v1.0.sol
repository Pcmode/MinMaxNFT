// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MinMaxNFT is ERC721, Ownable {
    using Strings for uint256; // Import the library for converting uint256 to string

    struct Character {
        uint256 health;
        uint256 level;
        uint256 attackPower;
        uint256 defense;
        uint256 dodge;
        uint256 speed;
        uint256 luck;
    }

    struct MechBot {
        uint256 health;
        uint256 level;
        uint256 attackPower;
        uint256 defense;
        uint256 dodge;
        uint256 speed;
        uint256 luck;
    }

    mapping(uint256 => Character) public characters;
    mapping(uint256 => MechBot) public mechbots;
    mapping(uint256 => string) private ipfsMetadataCIDs; // Mapping to store the IPFS CIDs for each token ID (metadata URIs)

    uint256 public nextCharacterId = 1;
    uint256 public nextMechBotId = 10**4;

    bool public mintingPaused;
    bool public contractAccessPaused;

    event CharacterMinted(address indexed owner, uint256 indexed characterId);
    event MechBotCreated(address indexed owner, uint256 indexed mechBotId);
    event MintingPaused(bool paused);
    event ContractAccessPaused(bool paused);
    event TokenIPFSURIUpdated(uint256 indexed tokenId, string ipfsURI);

    modifier whenMintingNotPaused() {
        require(!mintingPaused, "Minting is paused");
        _;
    }

    modifier whenContractAccessNotPaused() {
        require(!contractAccessPaused, "Contract access is paused");
        _;
    }

    constructor() ERC721("MinMaxNFTs", "MMNFT") {}

    function setMintingPaused(bool paused) external onlyOwner {
        mintingPaused = paused;
        emit MintingPaused(paused);
    }

    function setContractAccessPaused(bool paused) external onlyOwner {
        contractAccessPaused = paused;
        emit ContractAccessPaused(paused);
    }

    function createCharacter(
        uint256 health,
        uint256 level,
        uint256 attackPower,
        uint256 defense,
        uint256 dodge,
        uint256 speed,
        uint256 luck
    ) external payable whenContractAccessNotPaused whenMintingNotPaused {
        require(msg.value == 2000 ether, "Exact Amount of 2000 EGEM must be sent to buy NFT");
        characters[nextCharacterId] = Character(health, level, attackPower, defense, dodge, speed, luck);
        _safeMint(msg.sender, nextCharacterId);
        emit CharacterMinted(msg.sender, nextCharacterId);
        nextCharacterId++;

        // Send the ether spent when minting to a 0x address
        address payable receiver = payable(0xb7456ca13c861573D261432F5d11c8Ce603538a8);
        receiver.transfer(msg.value);
    }

    function createMechBot(
        uint256 health,
        uint256 level,
        uint256 attackPower,
        uint256 defense,
        uint256 dodge,
        uint256 speed,
        uint256 luck
    ) external payable whenContractAccessNotPaused whenMintingNotPaused {
        require(msg.value == 2000 ether, "Exact Amount of 2000 EGEM must be sent to buy NFT");
        mechbots[nextMechBotId] = MechBot(health, level, attackPower, defense, dodge, speed, luck);
        _safeMint(msg.sender, nextMechBotId);
        emit MechBotCreated(msg.sender, nextMechBotId);
        nextMechBotId++;

        // Send the ether spent when minting to a 0x address
        address payable receiver = payable(0xb7456ca13c861573D261432F5d11c8Ce603538a8);
        receiver.transfer(msg.value);
    }

    function updateTokenIPFSURI(uint256 tokenId, string memory ipfsURI) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        ipfsMetadataCIDs[tokenId] = ipfsURI;
        emit TokenIPFSURIUpdated(tokenId, ipfsURI);
    }

    function getIPFSLink(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");

        // Concatenate the base IPFS URL with the CID stored in the mapping
        string memory baseIPFSURL = "https://bafybeihrcqtdabkccnbknnmdii6d42qdeywfphc4r7465p7mjsrre3wkqu.ipfs.dweb.link/";
        string memory ipfsCID = ipfsMetadataCIDs[tokenId];

        // Combine the base URL and CID to form the complete IPFS link
        string memory ipfsLink = string(abi.encodePacked(baseIPFSURL, ipfsCID));

        return ipfsLink;
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
