//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './Dex.sol';
import "./interfaces/IDexFactory.sol";
import "hardhat/console.sol";


contract DexFactory is IDexFactory {
    
    mapping (address => mapping(address => address)) public override getPools;
    address[] public allPools;

    function createDex(
        address _tokenA,
        address _tokenB
    ) public override returns (address exchangeAddress) {
        console.log('CtokenA: ', _tokenA);
        console.log('CtokenB: ', _tokenB);
        require(_tokenA != _tokenB, "Identical Addresses");
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");
        require(getPools[_tokenA][_tokenB] == address(0), "tokens already exist");

        /// Create 1
        Dex exchange = new Dex(_tokenA, _tokenB);
        exchangeAddress = address(exchange);

        allPools.push(exchangeAddress);
        getPools[_tokenA][_tokenB] = exchangeAddress;
        getPools[_tokenB][_tokenA] = exchangeAddress;
        emit PoolCreated(_tokenA, _tokenB, exchangeAddress);
    }
}

        /// Create 2 with Instructions
        // bytes memory bytecode = type(Dex).creationCode;
        // bytes32 salt = keccak256(abi.encodePacked(_tokenA, _tokenB));
        // assembly {
        //    exchangeAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        // }