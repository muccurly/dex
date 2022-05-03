//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Math.sol";
contract Dex is ERC20 {
    using SafeMath for uint256;

    // address public factoryAddress;

    IERC20 public token1;
    IERC20 public token2;

    uint8 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(
        address _token1,
        address _token2
    ) ERC20("LP-Token", "LPT") {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        // factoryAddress = msg.sender;
    }

    function createPool(
        uint256 _amount1,
        uint256 _amount2
    ) external payable returns (uint256 amountLPTokens) {
        uint256 balance1 = token1.balanceOf(address(this));
        uint256 balance2 = token2.balanceOf(address(this));

        uint256 _totalSupply = totalSupply();

        if(_totalSupply == 0){
            amountLPTokens = Math.sqrt(_amount1.mul(_amount2));
        } else {
            amountLPTokens = Math.min(
                (_amount1 * _totalSupply)/ balance1,
                (_amount2 * _totalSupply)/ balance2);
        }
        token1.transferFrom(msg.sender, address(this), _amount1);
        token2.transferFrom(msg.sender, address(this), _amount2);
        _mint(msg.sender, amountLPTokens);
    }


    function withdraw() external returns (address) {

    } 

    
    function swap(
        uint _amount
    ) external payable lock{
       
    }

    
    function _getFee() private returns (uint256){

    }
}