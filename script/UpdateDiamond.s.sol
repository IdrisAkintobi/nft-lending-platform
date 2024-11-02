// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IDiamondCut } from "../src/interfaces/IDiamondCut.sol";
import { RepaymentFacet } from "../src/facets/RepaymentFacet.sol";
import { DiamondUtils } from "./helpers/DiamondUtils.sol";
import { Script, console } from "forge-std/Script.sol";

contract DiamondDeployerScript is DiamondUtils {
    //contract types of facets to be deployed
    address diamondAddr = 0x0c65D60940fa4afDb5eefA05D952d72a4d23FF3a;
    RepaymentFacet repaymentFacet;

    function setUp() public { }

    function run() public {
        // Start the broadcast
        vm.startBroadcast();

        repaymentFacet = new RepaymentFacet();

        //upgrade diamond with facets
        //build cut struct
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(repaymentFacet),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: DiamondUtils.generateSelectors("RepaymentFacet")
            })
        );

        //upgrade diamond
        IDiamondCut(diamondAddr).diamondCut(cut, address(0x0), "");

        // Stop broadcasting
        vm.stopBroadcast();

        console.log("Diamond updated successfully");
    }
}
