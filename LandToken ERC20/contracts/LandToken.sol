//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LandToken is ERC20 {
    uint constant _initial_supply = 100000000 * (10**18);
    constructor() ERC20("LandToken", "LAND") public {
        _mint(msg.sender, _initial_supply);
    }
}