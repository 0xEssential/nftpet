//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./MetadataGenerator.sol";
import "../NFTPet/NFTPet.sol";

contract YourPet is ERC721, Ownable, NFTPet {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() public ERC721("Loogies", "LOOG") {
        // RELEASE THE LOOGIES!
    }

    mapping(uint256 => bytes3) public color;
    mapping(uint256 => uint256) public chubbiness;

    function mintItem() public returns (uint256) {
        _tokenIds.increment();

        uint256 id = _tokenIds.current();
        _mint(msg.sender, id);

        NFTPet._adopt(id);

        bytes32 predictableRandom = keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, address(this)));
        color[id] =
            bytes2(predictableRandom[0]) |
            (bytes2(predictableRandom[1]) >> 8) |
            (bytes2(predictableRandom[2]) >> 16);
        chubbiness[id] = 35 + ((55 * uint256(uint8(predictableRandom[3]))) / 255);

        return id;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(_exists(id), "not exist");
        return MetadataGenerator.tokenURI(ownerOf(id), id, color[id], chubbiness[id]);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, NFTPet) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
