//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Math.sol";
import "./interfaces/IDexFactory.sol";
contract Dex is ERC20 {
    using SafeMath for uint256;

    IDexFactory public factory;

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
        require(_token1 != address(0) || _token2 != address(0), 'Invalid token address');
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        factory = IDexFactory(msg.sender);
    }

    function createPool(
        uint256 _amount1,
        uint256 _amount2
    ) external payable returns (uint256 amountLPTokens) {
        (address token1_, address token2_) = _getTokenAdresses();
        if(factory.getPools(token1_, token2_) == address(0)){
            factory.createDex(token1_, token2_);
        }

        (uint256 balance1, uint256 balance2) = _getReserves();
        uint256 _totalSupply = totalSupply();

        if(_totalSupply == 0){
            amountLPTokens = Math.sqrt(_amount1.mul(_amount2));
        } else {
            amountLPTokens = Math.min(
                    _amount1.mul(_totalSupply).div(balance1),
                    _amount2.mul(_totalSupply).div(balance2)
                );
        }
        require(amountLPTokens <= 0, 'Insufficiently balance');
        token1.transferFrom(msg.sender, address(this), _amount1);
        token2.transferFrom(msg.sender, address(this), _amount2);
        _mint(msg.sender, amountLPTokens);
    }


    function withdraw(uint256 _amount) external returns (address) {

    } 

    
    function swap(
        uint _amount,
        address _to
    ) external payable lock{
       
    }

    function _getTokenAdresses() internal view  returns (address tokenA, address tokenB) {
        (tokenA, tokenB) = (address(token1), address(token2));
    }

    function _getReserves() internal view  returns (uint256 reserveA, uint256 reserveB) {
        (reserveA, reserveB) = (token1.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    
    function _getFee() private returns (uint256){

    }
}