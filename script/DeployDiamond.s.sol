// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IDiamondCut } from "../src/interfaces/IDiamondCut.sol";
import { DiamondCutFacet } from "../src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../src/facets/DiamondLoupeFacet.sol";
import { OwnershipFacet } from "../src/facets/OwnershipFacet.sol";
import { LendingFacet } from "../src/facets/LendingFacet.sol";
import { RepaymentFacet } from "../src/facets/RepaymentFacet.sol";
import { Diamond } from "../src/Diamond.sol";
import { DiamondUtils } from "./helpers/DiamondUtils.sol";
import { Script, console } from "forge-std/Script.sol";

contract DiamondDeployerScript is DiamondUtils {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    LendingFacet lendingF;
    RepaymentFacet repaymentF;

    address owner;
    uint256 ltvRatio;
    uint256 interestRate;

    function setUp() public {
        owner = vm.envAddress("INITIAL_OWNER");
        ltvRatio = vm.envUint("LTV_RATIO");
        interestRate = vm.envUint("INITIAL_INTEREST_RATE");
    }

    function run() public {
        // Start the broadcast
        vm.startBroadcast();
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        //uint256 _ltvRatio, uint256 _interestRate)
        diamond = new Diamond(owner, address(dCutFacet), ltvRatio, interestRate);
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        lendingF = new LendingFacet();
        repaymentF = new RepaymentFacet();

        //upgrade diamond with facets
        //build cut struct
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](4);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(dLoupe),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: DiamondUtils.generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(ownerF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: DiamondUtils.generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(lendingF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: DiamondUtils.generateSelectors("LendingFacet")
            })
        );

        cut[3] = (
            IDiamondCut.FacetCut({
                facetAddress: address(repaymentF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: DiamondUtils.generateSelectors("RepaymentFacet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        // Stop broadcasting
        vm.stopBroadcast();

        console.log("Diamond deployed to:", address(diamond));
    }
}
