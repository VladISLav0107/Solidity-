// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./_ERC20_standard.sol";
import "./IterableMapping.sol";

contract Token is IERC20 {

    using IterableMapping for IterableMapping.Map;
    IterableMapping.Map private balanceOf;

    mapping(address => uint) public holderDevedents;

    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Devident Token";
    string public symbol = "Devid";
    uint8 public decimals = 18;
    uint public totalSupply = 100 ether;
    address private owner;
    
    constructor() {
    owner = msg.sender;
    balanceOf.set(owner, totalSupply);
    }

    function getSize() external view returns (uint){
        return balanceOf.size();
    } 

    function getKey(uint256 _key) external view returns (address){
        return balanceOf.getKeyAtIndex(_key);
    }

    function getBalance(address account) external view returns (uint256) {
        return balanceOf.get(account);
    }

    function _totalSupply() external view returns(uint256) {
        return totalSupply;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf.set(msg.sender, balanceOf.get(msg.sender) - amount);
        balanceOf.set(recipient, balanceOf.get(recipient) + amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf.set(sender, balanceOf.get(sender) - amount);
        balanceOf.set(recipient, balanceOf.get(recipient) + amount);
        return true;
    }

    function mint(uint amount) external {
        balanceOf.get(msg.sender) + amount;
        totalSupply += amount;
    }

    function burn(uint amount) external {
        balanceOf.get(msg.sender) - amount;
        totalSupply -= amount;
    }

    function writeDevedent() external payable {
        uint256 valueETH = msg.value;
        for(uint i = 0; i < balanceOf.size(); i++){
           address holderKey = balanceOf.getKeyAtIndex(i);
           holderDevedents[holderKey] = valueETH * balanceOf.get(holderKey) / totalSupply;
        }
    }

    function takeDevident() external {
        uint256 yourDevedent = holderDevedents[msg.sender];
        require(yourDevedent >= 0 , "your balance is empty");
        payable(msg.sender).transfer(yourDevedent);
        holderDevedents[msg.sender] = 0;
    }


}
