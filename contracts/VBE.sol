// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VBC {
    struct vbS {
        // the first bytes equal to the amount of usable vars you have
        // are reserved for pointers
        // EX if you want to read the value of x
        // you would first read the 4th byte of the storage slot
        // that returns you the position of the first byte of that var
        uint256 a; // usable var = 0
        uint256 b; // usable var = 32
        uint256 c; // usable var = 64
        uint256 x; // usable var = 96
        uint256 y; // usable var = 128
        uint256 z; // usable var = 192
        uint256 s; // required buffer var = 32
    }

    vbS public vbs;

    /**
      * @param action: Mathmatical action you want to perform on the value
      * @param svar: What value you want to perform the action on
      * @param num: The number you wish to use in your action
      *
      * Example:
      *    action = 3 (division)
      *    svar = 3 (x)
      *    num = 2
      *  The function will modify value x to equal div(x, 2)
      */
    function VBE(
        uint8 action,
        uint8 svar,
        uint256 num
    ) public returns (uint256 newsvar) {
        assembly {
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
            // spos is agnostic to storage slots
            // so we need to calculate what storage slot we are starting in
            let spos := byte(svar, vptr) // get the starting position of svar
            // what storage slot does our var start in
            let sb := div(spos, 0x20)
            let rem := mod(spos, 0x20)
            switch sb
            case 0 {}
            default { vptr := sload(add(vbs.slot, sb)) spos := sub(spos, mul(sb, 0x20)) }

            // byte buffer
            let b := 0x0
            // find the v we are looking for and vbd to fetch its val
            for { let idx := 0 } lt(idx, 0x21) { idx := add(idx, 1) } {
                // get the current byte
                b := byte(idx, vptr)
                // append the last 7 bits of b to v
                switch v
                case 0 {
                    v := shr(1, b)
                }
                default {
                    v := or(shl(7, v), shr(1, b))
                }
                if gt(b, 0x7F) { break }
                // if we are going into the next storage slot...
                if eq(rem, idx) { vptr := sload(add(vbs.slot, div(idx, 0x20))) }
            }
        }
    }
}