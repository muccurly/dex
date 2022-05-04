//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Math.sol";
import "./interfaces/IDexFactory.sol";
contract Dex is ERC20 {
    using SafeMath for uint256;

    event Swap(
        address indexed sender,
        address indexed to,
        uint256 amount1,
        uint256 amount2
    );

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
        _mint(msg.sender, amountLPTokens);
    }

    function withdraw(uint256 _amount) external returns (uint256 token1Amount, uint256 token2Amount) {
        require(_amount <= 0, 'Invalid amount');
        (uint256 balance1, uint256 balance2) = _getReserves();
        token1Amount = balance1.mul(_amount).div(totalSupply());
        token2Amount = balance2.mul(_amount).div(totalSupply());
        _burn(msg.sender, _amount);

        token1.transferFrom(address(this), msg.sender, _amount);
        token2.transferFrom(address(this), msg.sender, _amount);
    } 

    
    function swap(
        uint256 _amount1,
        uint256 _amount2,
        address _to
    ) external payable lock{
        require(_amount1 == 0 && _amount2 == 0, 'Insufficient Amount');

        (uint256 reserve1_, uint256 reserve2_ ) = _getReserves();
        (address token1_, address token2_) = _getTokenAdresses();

        uint256 amount1Out = _getAmount(
            _amount1,
            reserve1_,
            reserve2_
        );

         uint256 amount2Out = _getAmount(
            _amount2,
            reserve1_,
            reserve2_
        );


        require(_amount1 > reserve1_ || _amount2 > reserve2_, 'Insufficient Liquidity');

        if(amount1Out > 0) _transfer(token1_, _to, amount1Out);
        if(amount2Out > 0) _transfer(token2_, _to, amount2Out);

        emit Swap(msg.sender, _to, _amount1, _amount2);
    }

    function _getAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) private pure returns (uint256) {
        require(inputReserve == 0 || outputReserve == 0, "invalid reserves");

        uint256 inputAmountWithFee = inputAmount * 997;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 1000) + inputAmountWithFee;

        return numerator / denominator;
    }

    function _getTokenAdresses() internal view  returns (address tokenA, address tokenB) {
        (tokenA, tokenB) = (address(token1), address(token2));
    }

    function _getReserves() internal view  returns (uint256 reserveA, uint256 reserveB) {
        (reserveA, reserveB) = (token1.balanceOf(address(this)), token1.balanceOf(address(this)));
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