//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Script } from "forge-std/Script.sol";
import { MockNFT } from "../test/mocks/MockNFT.sol";

contract DeployMockNFT is Script {
    MockNFT mockNFT;

    function setUp() public { }

    function run() public returns (MockNFT) {
        vm.startBroadcast();
        mockNFT = new MockNFT();
        vm.stopBroadcast();
        return mockNFT;
    }
}
