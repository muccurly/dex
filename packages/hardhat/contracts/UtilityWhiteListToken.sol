//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract UtilityWhiteListToken is AccessControl, ERC20 {
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialValue,     
        address[] memory whiteList
        )  ERC20(name, symbol){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(WHITELIST_ROLE, _msgSender());
        
        for (uint i = 0; i < whiteList.length; i++) {
            grantRole(WHITELIST_ROLE, whiteList[i]);
        }

        _mint(_msgSender(), initialValue);
    }

    function addToWhiteList(address account) external {
        grantRole(WHITELIST_ROLE, account);
    }

    function removeFromWhiteList(address account) external {
        revokeRole(WHITELIST_ROLE, account);
    }
     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(hasRole(WHITELIST_ROLE, to) && hasRole(WHITELIST_ROLE, from), 'Does not exist address');
        super._beforeTokenTransfer(from, to, amount);
    }
}
