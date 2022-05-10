//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Math.sol";
import "./interfaces/IDex.sol";
import "./interfaces/IDexFactory.sol";
import "hardhat/console.sol";

contract Dex is IDex, ERC20 {
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
        require(_token1 != address(0) && _token2 != address(0), 'Invalid token address');
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        factory = IDexFactory(_msgSender());
    }

    function createPool(
        uint256 _amount1,
        uint256 _amount2
    ) external payable override returns (uint256 amountLPTokens) {
        (uint256 balance1, uint256 balance2) = getReserve();
        uint256 _totalSupply = totalSupply();

        if(_totalSupply == 0){
            amountLPTokens = Math.sqrt(_amount1.mul(_amount2));
        } else {
            amountLPTokens = Math.min(
                    _amount1.mul(_totalSupply).div(balance1),
                    _amount2.mul(_totalSupply).div(balance2)
                );
        }
        console.log("Contract LP tokens: ",amountLPTokens);
        require(amountLPTokens > 0, 'Insufficiently balance');
        assert(token1.transferFrom(_msgSender(), address(this), _amount1));
        assert(token2.transferFrom(_msgSender(), address(this), _amount2));
    
        _mint(_msgSender(), amountLPTokens);
    }

    function withdraw(uint256 _amount)
     external override returns ( uint256 token1Amount, uint256 token2Amount) {
        require(_amount > 0, 'Invalid amount');
        (uint256 balance1, uint256 balance2) = getReserve();
        token1Amount = balance1.mul(_amount).div(totalSupply());
        token2Amount = balance2.mul(_amount).div(totalSupply());
        _burn(_msgSender(), _amount);

        assert(token1.transfer(_msgSender(), token1Amount));
        assert(token2.transfer(_msgSender(), token2Amount));
    } 

    
    function swap(
        uint256 _amount1In,
        uint256 _amount2In
    ) external payable override lock{
        require(_amount1In == 0 || _amount2In == 0, 'Invalid Amount');

        (uint256 reserve1_, uint256 reserve2_ ) = getReserve();

        uint256 amount2Out = _getAmount(
            _amount1In,
            reserve1_,
            reserve2_
        );

         uint256 amount1Out = _getAmount(
            _amount2In,
            reserve2_,
            reserve1_
        );

        require(amount1Out < reserve1_ && amount2Out < reserve2_, 'Insufficient Liquidity');

        if(amount1Out > 0){
            console.log("(Swap)1 amountOut : ", amount1Out);
            assert(token1.transferFrom(_msgSender(), address(this), amount1Out));
            assert(token2.transfer(_msgSender(), _amount2In));
           }
        if(amount2Out > 0){
            console.log("(Swap)2 amountOut : ", amount2Out);
            
            assert(token2.transfer(_msgSender(), amount2Out));
            assert(token1.transferFrom(_msgSender(), address(this), _amount1In));
         }
        emit Swap(_msgSender(), _amount1In, _amount2In);
    }

    function _getAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) private pure returns (uint256) {
        require(inputReserve != 0 && outputReserve != 0, "invalid reserves");

        uint256 inputAmountWithFee = inputAmount * 997;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 1000) + inputAmountWithFee;

        return numerator / denominator;
    }

    function _getTokenAdresses() internal view  returns (address tokenA, address tokenB) {
        (tokenA, tokenB) = (address(token1), address(token2));
    }

    function getReserve() public view  returns (uint256 reserveA, uint256 reserveB) {
        (reserveA, reserveB) = (token1.balanceOf(address(this)), token2.balanceOf(address(this)));
    }
}

    // function addLiquidity(
    //     uint256 _amount1,
    //     uint256 _amount2
    // ) external payable returns (uint256 amountLPTokens){
    //     (address token1_, address token2_) = _getTokenAdresses();
    //     if(factory.getPools(token1_, token2_) == address(0)){
    //         factory.createDex(token1_, token2_);
    //     }
    //     address poolAddress = factory.getPools(token1_, token2_);
    //     token1.transferFrom(msg.sender, poolAddress, _amount1);
    //     token2.transferFrom(msg.sender, poolAddress, _amount2);
    //     createPool(_amount1,_amount2); 
    // }