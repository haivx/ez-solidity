//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IERC20.sol";

 abstract contract TokenSampleToken is IERC20 {
    uint256 private _totalSupply;
    //mapping[address] => balances
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _totalSupply           = 1000000;
        _balances[msg.sender]  = 1000000;
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(_balances[msg.sender] >= amount);
        _balances[msg.sender] -= amount; 
        _balances[to] += amount; 

        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(_balances[from] >= amount);
        require(_allowances[from][msg.sender] >= amount);

        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }


    function approve(address spender, uint256 amount) public override returns (bool) {
         _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }
}