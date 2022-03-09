// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract Crud {
    struct Player {
        uint id;
        string name;
    }

    Player[] public player;
    uint public nextId = 1;

    function loop(uint id) public view returns (uint256 _id) {
        bool notExisted = true;
        for (uint256 i = 0; i < player.length; i++) {
            if (player[i].id == id) {
                notExisted = false;
                return i;
            }
        }
        revert("No data's existed");
    }

    function create(string memory name) public {
        player.push(Player(nextId, name));
        nextId++;
    }

    function read(uint256 id) public view returns (uint256, string memory) {
        uint256 i = loop(id);
        return (player[i].id, player[i].name);
    }

    function update(uint id, string memory name) public {
        uint256 i = loop(id);
        player[i].name = name;
    }

    function deletei(uint id) public {
        uint256 i = loop(id);
        delete player[i];
    }
}