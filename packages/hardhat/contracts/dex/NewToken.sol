// contracts/Token.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NewToken is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _toMint
    ) ERC20(_name, _symbol) {
        _mint(_toMint, _initialSupply);
    }
}