//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IDexFactory {
    event PoolCreated(
        address indexed tokenA,
        address indexed tokenB,
        address pool   
    );

    /*  
        @dev tokenA/tokenB => tokenB/tokenA => Dex address
    */
    function getPools(address tokenA, address tokenB) external view returns (address pool); 
    function createDex(address _tokenA,address _tokenB) external returns (address exchangeAddress);
}