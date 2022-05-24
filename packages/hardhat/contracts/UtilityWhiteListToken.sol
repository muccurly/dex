//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IWhitelist.sol";
import "hardhat/console.sol";

contract UtilityWhiteListToken is AccessControl, ERC20 {
        IWhitelist whitelistRouter;
        constructor(
        string memory name,
        string memory symbol,
        uint256 initialValue,
        address whitelist     
        )  ERC20(name, symbol){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        whitelistRouter = IWhitelist(whitelist);

        _mint(_msgSender(), initialValue);
    }


    function mint(address to, uint amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(from, amount);
    }

     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(whitelistRouter.isWhitelisted(address(this), to), 'UtilityWhiteListToken: Does not exist address');
        super._beforeTokenTransfer(from, to, amount);
    }
}
