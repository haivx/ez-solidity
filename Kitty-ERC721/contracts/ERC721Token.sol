//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721TokenReceiver.sol";

library Address {
    /**
     * @dev Returns whether the target address is a contract.
     * @param _addr Address to check.
     * @return addressCheck True if _addr is a contract, false if not.
     */
    function isContract(address _addr)
        internal
        view
        returns (bool addressCheck)
    {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(_addr)
        }
        addressCheck = (codehash != 0x0 && codehash != accountHash);
    }
}

contract ERC721Token is ERC721 {
    mapping(address => uint256) public ownerToTokenCount;
    mapping(uint256 => address) private idToOwner;
    bytes4 internal constant  IDENTIFIER_ERC721 = 0x150b7a02;

    function balanceOf(address _owner) external view returns (uint256) {
        return ownerToTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return idToOwner[_tokenId];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        require(msg.sender == _from, "Can authorized the transfer token");
        require(
            _from == idToOwner[_tokenId],
            "Can authorized the transfer token"
        );
        ownerToTokenCount[_from] -= 1;
        ownerToTokenCount[_to] += 1;
        idToOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) internal {
        require(msg.sender == _from, "Can authorized the transfer token");
        require(
            _from == idToOwner[_tokenId],
            "Can authorized the transfer token"
        );
        ownerToTokenCount[_from] -= 1;
        ownerToTokenCount[_to] += 1;
        idToOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);

        if (_to.isContract()) {
            ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
        }
        require(retval  = IDENTIFIER_ERC721, "That is smart contract, so can't transfer token");
    }
}
