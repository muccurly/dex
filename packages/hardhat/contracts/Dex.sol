//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Math.sol";
contract Dex is ERC20 {
    using SafeMath for uint;

    address public factoryAddress;

    address public token1;
    address public token2;
    constructor(
        address _token1,
        address _token2
    ) ERC20("LP-Token", "LPT") {
        token1 = _token1;
        token2 = _token2;
        factoryAddress = msg.sender;
    }

    function createPool(
        uint256 _amount1,
        uint256 _amount2
    ) external payable returns (uint256 amountLPTokens) {
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint balance2 = IERC20(token2).balanceOf(address(this));

        // check is initialized or not
        if(totalSupply() == 0){
            // amountLPTokens = Math.sqrt(_amount1.mul(_amount2));
            IERC20(token1).transferFrom(msg.sender, address(this), _amount1);
            IERC20(token2).transferFrom(msg.sender, address(this), _amount2);

            _mint(msg.sender, amountLPTokens);
        } else {
            // total * 
        }

    }

    function withdraw() external returns (address) {

    } 
    
    function swap(
        uint _amount
    ) external payable{
       
    }
    
    function _getFee() private returns (uint256){
        
    }
}