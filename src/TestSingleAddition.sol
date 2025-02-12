// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TestSingleAddition {
    function run() public {
        assembly {
            let inputSize := 4
            let input := mload(0x40) // Load the free memory pointer
            for {
                let i := 0
            } lt(i, 6666666) {
                i := add(i, 1)
            } {
                mstore(input, inputSize) // Store the length of the array at the first slot
                mstore(0x40, add(input, mul(add(inputSize, 1), 0x20)))
                // P1 is generator of G1 and P2 is generator of G2
                // This computes [P1,P2,-P1,P2]
                mstore(
                    add(input, 0x20),
                    14109211638066327101576789954737745153085276800785764314279034197079128887632
                ) // input[0] = 1
                mstore(
                    add(input, 0x40),
                    8930651240158052377730918916261562433037303951273167267609837947345142120594
                ) // input[1] = 2
                mstore(
                    add(input, 0x60),
                    19580774378347519793615213803939661746755580026631262849253298658671705022774
                ) // input[2]
                mstore(
                    add(input, 0x80),
                    8828401767452049897559120356248481497961580895909545974388798342335181756057
                ) // input[3]
                let success := call(
                    sub(gas(), 2000),
                    6,
                    0,
                    add(input, 0x20),
                    mul(inputSize, 0x20),
                    0x40,
                    0x40
                )
                switch success
                case 0 {
                    revert(0, 0)
                }
                let result := mload(0x40)
                if iszero(result) {
                    revert(1, 1)
                }
            }
            sstore(1, 1)
        }
    }
}
