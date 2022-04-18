 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Gold is ERC20, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    mapping(address => bool) private _blacklist;
    event BlacklistAdded(address account);
    event BlacklistRemoved(address account);

    constructor() ERC20("GOLD", "GLD") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer (
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(_blacklist[from] == false, "Gold: Account sender was on blacklist");
        require(_blacklist[to] == false, "Gold: account recipient was on blacklist");
        super._beforeTokenTransfer(from, to, amount);
    }

    function addToBlackList(address _account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_account != msg.sender, "Gold: Can not add sender to blacklist");
        require(_blacklist[_account] == false, "Gold: account was on blacklist");

        _blacklist[_account] = true;
        emit BlacklistRemoved(_account);
    }

    function removeFromBlackList(address _account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_blacklist[_account] == true, "Gold: Account was not on blacklist");
        _blacklist[_account] = false;
        emit BlacklistAdded(_account);
    }
}