// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import './interfaces/IWhitelist.sol';
import "@openzeppelin/contracts/utils/Context.sol";


contract Whitelist is IWhitelist, Context {
    address public owner;

    mapping(address => mapping(address => bool)) private _isWhitelisted;
    mapping(address => bool) public override isRegistered;
    mapping(address => bool) public isOperator;

    modifier validateToken(address token_) {
        require(token_ != address(0), "Whitelist: INVALID_TOKEN_ADDRESS");
        require(isRegistered[token_], "Whitelist: TOKEN_NOT_REGISTERED");
        _;
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "Whitelist: NOT_OWNER");
        _; 
    }

    modifier onlyOperator() {
        require(isOperator[_msgSender()], "Whitelist: NOT_OPERATOR");
        _;
    }

    constructor(
        address admin_,
        address [] memory operators_
    ){
        require(admin_ != address(0), "Whitelist: INVALID_ADMIN_ADDRESS");
        owner = admin_;
        for (uint i = 0; i < operators_.length; i++) {
            isOperator[operators_[i]] = true;
        }
    }

    function addOperator(address operator_) external onlyOwner() {
        require(operator_ != address(0), "Whitelist: INVALID_ACCOUNT_ADDRESS");

        isOperator[operator_] = true;
    }

    function removeOperator(address operator_) external onlyOwner() {
        require(operator_ != address(0) && isOperator[operator_], "Whitelist: INVALID_ACCOUNT_ADDRESS");

        isOperator[operator_] = false;
    }
    
    function addToken(address token_) external onlyOperator() {
        require(token_ != address(0), "INVALID_TOKEN_ADDRESS");
        isRegistered[token_] = true;
    }

    function removeToken(address token_) external validateToken(token_) onlyOperator() {
        isRegistered[token_] = false;
    }

    function whitelist(address token_, address target_)
        external
        override 
        validateToken(token_) 
        onlyOperator() 
    {
        require(target_ != address(0), "Whitelist: INVALID_ADDRESS");

        _isWhitelisted[token_][target_] = true;
    }

    function dewhitelist(address token_, address target_)
        external
        override
        validateToken(token_)
        onlyOperator()
    {
        require(target_ != address(0), "Whitelist: INVALID_ADDRESS");

        _isWhitelisted[token_][target_] = false;
    }

    function batchWhitelist(address token_, address[] memory targets_)
        external
        override
        validateToken(token_)
        onlyOperator()
    {
        for (uint256 i = 0; i < targets_.length; i++) {
            _isWhitelisted[token_][targets_[i]] = true;
        }
    }

    function batchDewhitelist(address token_, address[] memory targets_)
        external
        override
        validateToken(token_)
    {
        for (uint256 i = 0; i < targets_.length; i++) {
            _isWhitelisted[token_][targets_[i]] = false;
        }
    }

    function isWhitelisted(address token_, address target_)
        external
        view
        override
        validateToken(token_)
        returns (bool)
    {
        require(target_ != address(0), "Whitelist: INVALID_ADDRESS");

        if(isRegistered[token_]){
            return _isWhitelisted[token_][target_];
        }
        return false;
    }
}