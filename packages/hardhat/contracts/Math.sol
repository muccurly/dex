//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Math {
    /**
     * @dev Returns the square root of a number.
     */
    function sqrt(uint256 x) public pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}