//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './Dex.sol';
contract DexFactory {
    
    event PoolCreated(
        address indexed tokenA,
        address indexed tokenB,
        address pool   
    );

    mapping (address => mapping(address => address)) public getPools;
    address[] public allPools;

    function createDex(
        address _tokenA,
        address _tokenB
    ) public returns (address exchangeAddress) {
        require(_tokenA != address(0) || _tokenB != address(0), "Invalid token address");
        require(getPools[_tokenA][_tokenB] != address(0), "Dex of this tokens already exist");

        
        Dex exchange = new Dex(_tokenA, _tokenB);
        exchangeAddress = address(exchange);
        allPools.push(exchangeAddress);
        getPools[_tokenA][_tokenB] = exchangeAddress;
        getPools[_tokenB][_tokenA] = exchangeAddress;
    }
}