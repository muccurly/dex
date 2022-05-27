// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IWhitelist {
 function whitelist(address token_, address target_) external;
 function dewhitelist(address token_, address target_) external;

 function batchWhitelist(address token_, address[] memory targets_) external;
 function batchDewhitelist(address token_, address[] memory targets_) external;

 function isWhitelisted(address token_, address target_) external view returns (bool);
 function isRegistered(address token_) external view returns (bool);
}