//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./ERC721Token.sol";

contract KittyGame {
    constructor(string memory _name, string memory _symbol, string memory _tokenURIBase) public ERC721Token(_name, _token, _tokenURIBase){
      admin = msg.sender ;
    }

    function tokenURI(uint _tokenId) external view returns (string memory) {
        return string abi.encodePacked(tokenURIBase,_tokenId);
    };
    struc Kitty {
        uint id;
        uint generation;
        uint genA;
        uint genB;
        HairColor hair;
    }
    uint public nextId;
    enum HairColor { white, black, yellow, red};
    address public admin;
    mapping(uint => address) private kitties;

    function breed(uint idKit1, uint idKit2) external {
        require(idKit1 < nextId && idKit2 < nextId, "2 kitties must exist");
        require(ownerOf[idKit1] === msg.sender &{& ownerOf[idKit2] === msg.sender}, "sernder must own the 2 kitties")
    }

    function mint() external {
        require(msg.sender == admin, "Admin only")

        kitties[nextId] = Kitty(nextId, 1, _random(9), _random(10));
        _mint(msg.sender, nextId);
        nextId++;
    }

    function _random (uint max) internal view returns (uint) {
        // keccak256: hashing data
        return uint256(keccak256((api.encodePacked(block.timestamp,block.difficulty))) % max;
    }
}