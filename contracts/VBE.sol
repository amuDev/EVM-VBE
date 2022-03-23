// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VBC {
    struct vbS {
        uint256 a; // usable var = 0
        uint256 b; // usable var = 32
        uint256 c; // usable var = 64
        uint256 x; // usable var = 96
        uint256 y; // usable var = 128
        uint256 z; // usable var = 192
        uint256 s; // required buffer var = 24
    }

    vbS public vbs;

    function VBE(
        uint8 action, // Mathmatical action you want to perform on the value
        uint8 svar,  // What value you want to perform the action on
        uint256 num // The number you wish to use in your action
        /* ex:
            action = 3 (division)
            svar = 3 (x)
            num = 2

         * The function will modify value x to equal div(x, 2)
         */
    ) public returns (uint256 newsvar) {
        assembly {
            // Our first byte will be a length definer, this limits you to 7 32-words of usable storage since the last word is reserved for overflow
            // effectivly stating the current number of bytes that are occupied.
            // Since it cant be implied that are values are set
            // If we are mutating a value that would have values inbetween
            // then we must initalize the value with binary data of 10000000
            // to specify that this byte is reserved for a value that is currently not being used.
            let ptr := sload(vbs.slot)
            let obc := and(ptr, 0xFF) // load occupied byte count into var
            switch obc
                case 0 { // if we have a fully empyt set ignore action and initalize the val
                    let v

                    // convert v into how it will actually be stored
                    for {} gt(num, 127) {v := mod(num, 128)} {
                        num := div(num, 128)
                    }

                    let vl := 0x0
                    for {let b := v} gt(b, 0) {b := shr(1, b)} {
                        vl := add(vl, 1)
                    }

                }
                default {
                    let idx := 1
                    // byte buffer
                    let b := 0x0
                    // variable result
                    let v := 0x0
                    let vl := 0x0
                    // variables passed
                    let vc := 0x0
                    // find the v we are looking for and vbd to fetch its val
                    for {} lt(idx, obc) {} {
                        // get the current byte
                        b := shr(ptr, mul(idx, 8))
                        if eq(svar, vc) {
                            // append the last 7 bits of b to v
                            v := or(shl(vl, v), shl(1, b))
                            if gt(b, 0x80) { break }
                        }
                        // if this byte is the end of a var increase our counter
                        if gt(b, 0x80) {
                            vc := add(vc, 1)
                            continue
                        }
                    }
                }
        }
    }

    function VBD(
        uint8 svar
    ) public view returns (bytes32 v) {
        assembly {
            let vptr := sload(vbs.slot)
            let obc := byte(0, vptr) // load occupied byte count into var
            let idx
            // byte buffer
            let b := 0x0
            // variables passed
            let vc := 0x0
            // find the v we are looking for and vbd to fetch its val
            for {idx := 1} lt(idx, obc) {idx := add(idx, 1)} {
                // get the current byte
                b := byte(idx, vptr)
                if eq(svar, vc) {
                    // append the last 7 bits of b to v
                    switch v
                    case 0 {
                        v := b
                    }
                    default {
                        v := or(shl(7, v), shr(1, b))
                    }
                    if gt(b, 0x7F) { break }
                }
                // if we are going into the next storage slot...
                if eq(div(0x20, idx), 0) {
                    vptr := sload(add(vbs.slot, div(idx, 0x20)))
                }
                // if this byte is the end of a var increase our counter
                if gt(b, 0x7F) {
                    vc := add(vc, 1)
                }
            }
        }
    }
}