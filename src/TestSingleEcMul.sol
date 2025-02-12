// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TestSingleEcMul {
    function run() public {
        assembly {
            let
                x_value
            := 0x2cdddce3dbb7a8e7206c2b56b1f0891cdea5dbec8ac4946a015b1cd22e03a1f3
            let
                y_value
            := 0x270eb5d3ff58cf311016b96a51422004d77f16cea71157a72ee9505e8cf9eff2
            let
                scalar_value
            := 0x216b3618ff117720c9eb701ca2547eef411de4cd47115dcde2ce5e0686ac50dc
            let input := mload(0x40)
            // The number of times precompile can be called at 1 bill gas limit 166666
            for {
                let i := 0
            } lt(i, 166666) {
                i := add(i, 1)
            } {
                mstore(input, x_value)
                mstore(add(input, 0x20), y_value)
                mstore(add(input, 0x40), scalar_value)
                let success := staticcall(
                    6000, // Pass all available gas
                    0x07, // Precompiled contract address for elliptic curve multiplication
                    input, // Pointer to the input data in memory
                    0x60, // Input size (96 bytes)
                    0x00, // Output location (we don't need an output in this example)
                    0x20 // Output size (32 bytes, if you need to capture it)
                )
                if iszero(success) {
                    revert(0, 1) // Revert if the static call failed
                }
            }
            sstore(1, 1)
        }
    }
}
