// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TestSinglePairing {
    function run() public {
        assembly {
            let inputSize := 12
            let input := mload(0x40) // Load the free memory pointer
            for {
                let i := 0
            } lt(i, 8849) {
                i := add(i, 1)
            } {
                mstore(input, inputSize) // Store the length of the array at the first slot
                mstore(0x40, add(input, mul(add(inputSize, 1), 0x20)))
                // P1 is generator of G1 and P2 is generator of G2
                // This computes [P1,P2,-P1,P2]
                mstore(add(input, 0x20), 1) // input[0] = 1
                mstore(add(input, 0x40), 2) // input[1] = 2
                mstore(
                    add(input, 0x60),
                    11559732032986387107991004021392285783925812861821192530917403151452391805634
                ) // input[2]
                mstore(
                    add(input, 0x80),
                    10857046999023057135944570762232829481370756359578518086990519993285655852781
                ) // input[3]
                mstore(
                    add(input, 0xA0),
                    4082367875863433681332203403145435568316851327593401208105741076214120093531
                ) // input[4]
                mstore(
                    add(input, 0xC0),
                    8495653923123431417604973247489272438418190587263600148770280649306958101930
                ) // input[5]
                mstore(add(input, 0xE0), 1) // input[6]
                mstore(
                    add(input, 0x100),
                    21888242871839275222246405745257275088696311157297823662689037894645226208581
                ) // input[7]
                mstore(
                    add(input, 0x120),
                    11559732032986387107991004021392285783925812861821192530917403151452391805634
                ) // input[8]
                mstore(
                    add(input, 0x140),
                    10857046999023057135944570762232829481370756359578518086990519993285655852781
                ) // input[9]
                mstore(
                    add(input, 0x160),
                    4082367875863433681332203403145435568316851327593401208105741076214120093531
                ) // input[10]
                mstore(
                    add(input, 0x180),
                    8495653923123431417604973247489272438418190587263600148770280649306958101930
                ) // input[11]
                let success := call(
                    sub(gas(), 2000),
                    8,
                    0,
                    add(input, 0x20),
                    mul(inputSize, 0x20),
                    0x40,
                    0x20
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
