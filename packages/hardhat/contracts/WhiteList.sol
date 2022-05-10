//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract UtilityWhiteListToken is AccessControl, ERC20 {
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    constructor(
        string memory name,
        string memory symbol,
        address[] memory whiteList
        )  ERC20(name, symbol){
        _setupRole(WHITELIST_ROLE, _msgSender());

        for (uint i = 0; i < whiteList.length; i++) {
            revokeRole(WHITELIST_ROLE, whiteList[i]);
        }
    }

     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(hasRole(WHITELIST_ROLE, from), 'Does not have access');
        super._beforeTokenTransfer(from, to, amount);
    }
}
