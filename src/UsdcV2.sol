// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";
import "./Ownable.sol";

contract UsdcV2 is ERC20, Ownable {
    mapping(address => bool) public whitelist;

    modifier onlyWhitelist {
        require(msg.sender != address(0));
        require(whitelist[msg.sender]);
        _;
    }

    constructor(string memory _name, string memory _symbol, uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {
        initializeOwnable(msg.sender);
    }

    function addUserToWhitelist(address account) public onlyWhitelist {
        whitelist[account] = true;
    }

    function removeUserFromWhitelist(address account) public onlyWhitelist {
        whitelist[account] = false;
    }

    function isUserInWhitelist(address account) public returns (bool) {
        return whitelist[account];
    }

    function mint(address to, uint256 amount) public onlyWhitelist{
        require(whitelist[msg.sender], "This address don't have the authority to mint");
        super._mint(to, amount);
    }

    function transfer(address to, uint256 amount) public view override returns (bool) {
        require(whitelist[msg.sender], "This address don't have the authority to transfer");
        return true;
    }
}