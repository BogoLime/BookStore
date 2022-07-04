//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract LIBToken is ERC20PresetMinterPauser {
    constructor() ERC20PresetMinterPauser("Library Token", "LIB"){
        
    }
}