//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './Dex.sol';

contract DexFactory {
    /*  
    @dev tokenA/tokenB => tokenB/tokenA => Dex address
    */
    mapping (address => mapping(address => address)) public dexs;
    address[] public dexArray;

    event PoolCreated(
        address tokenA,
        address tokenB,
        address pool      
    );

    function createDex(
        address _token1,
        address _token2
    ) public returns (address exchangeAddress) {
        require(_token1 != address(0) || _token2 != address(0), "Invalid token address");
        require(dexs[_token1][_token2] != address(0), "Dex of this tokens already exist");

        
        Dex exchange = new Dex(_token1, _token2);
        exchangeAddress = address(exchange);
        dexArray.push(exchangeAddress);
        dexs[_token1][_token2] = exchange;
        dexs[_token2][_token1] = exchange;
    }
}