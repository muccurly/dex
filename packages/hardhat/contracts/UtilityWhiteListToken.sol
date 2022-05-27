//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IWhitelist.sol";
import "hardhat/console.sol";

contract UtilityWhiteListToken is ERC20 {
        IWhitelist public whitelistRouter;
        address owner;

        modifier onlyOwner() {
            require(owner == _msgSender(), "Whitelist: NOT_OWNER");
            _; 
        }
        constructor(
        string memory name,
        string memory symbol,
        address whitelist     
        )  ERC20(name, symbol){
        owner = _msgSender();
        whitelistRouter = IWhitelist(whitelist);
    }


    function mint(address to, uint amount) external onlyOwner() {
        _mint(to, amount);
    }

    function burn(address from, uint amount) external onlyOwner() {
        _burn(from, amount);
    }

     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if(from != address(0) && to != address(0)){
            require(whitelistRouter.isWhitelisted(address(this), to), 'UtilityWhiteListToken: Does not exist address');
        }
        super._beforeTokenTransfer(from, to, amount);
    }
}
