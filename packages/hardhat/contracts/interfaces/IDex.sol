//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IDex{
    event Swap(
        address indexed swaper,
        uint256 amount1,
        uint256 amount2
    );
    
    function createPool(uint256 _amount1,uint256 _amount2) external payable returns (uint256 amountLPTokens);
    function withdraw(uint256 _amount) external returns (uint256 token1Amount, uint256 token2Amount);
    function swap(uint256 _amount1In,uint256 _amount2In) external payable; 
}