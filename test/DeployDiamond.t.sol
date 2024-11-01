// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IDiamondCut } from "../src/interfaces/IDiamondCut.sol";
import { DiamondCutFacet } from "../src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../src/facets/DiamondLoupeFacet.sol";
import { OwnershipFacet } from "../src/facets/OwnershipFacet.sol";
import { LendingFacet } from "../src/facets/LendingFacet.sol";
import { RepaymentFacet } from "../src/facets/RepaymentFacet.sol";
import { Diamond } from "../src/Diamond.sol";
import { DiamondUtils } from "../script/helpers/DiamondUtils.sol";
import { Test, console } from "forge-std/Test.sol";

contract DiamondDeployerScript is DiamondUtils, Test {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    LendingFacet lendingF;
    RepaymentFacet repaymentF;

    address owner = address(this);
    uint256 ltvRatio = 50;
    uint256 interestRate = 500; //50%

    function setUp() public {
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
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(ownerF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(lendingF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("LendingFacet")
            })
        );

        cut[3] = (
            IDiamondCut.FacetCut({
                facetAddress: address(repaymentF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RepaymentFacet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");
    }

    function testDeployDiamond() public view {
        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }
}
