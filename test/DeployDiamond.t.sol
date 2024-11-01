// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IDiamondCut } from "../src/interfaces/IDiamondCut.sol";
import { IERC721 } from "../src/interfaces/IERC721.sol";
import { DiamondCutFacet } from "../src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../src/facets/DiamondLoupeFacet.sol";
import { OwnershipFacet } from "../src/facets/OwnershipFacet.sol";
import { LendingFacet } from "../src/facets/LendingFacet.sol";
import { RepaymentFacet } from "../src/facets/RepaymentFacet.sol";
import { Diamond } from "../src/Diamond.sol";
import { DiamondUtils } from "../script/helpers/DiamondUtils.sol";
import { Test, console } from "forge-std/Test.sol";
import { MockNFT } from "./mocks/MockNFT.sol";
import { Collateral } from "../src/contracts/Collateral.sol";

contract DiamondDeployerScript is DiamondUtils, Test {
    address owner = address(this);
    uint256 ltvRatio = 50;
    uint256 interestRate = 500; //50%

    address borrower = 0x440Bcc7a1CF465EAFaBaE301D1D7739cbFe09dDA;
    uint256 tokenId = 1;

    //deploy facets
    DiamondCutFacet dCutFacet = new DiamondCutFacet();
    //uint256 _ltvRatio, uint256 _interestRate)
    Diamond diamond = new Diamond(owner, address(dCutFacet), ltvRatio, interestRate);
    DiamondLoupeFacet dLoupe = new DiamondLoupeFacet();
    OwnershipFacet ownerF = new OwnershipFacet();
    LendingFacet lendingF = new LendingFacet();
    RepaymentFacet repaymentF = new RepaymentFacet();
    MockNFT mockNFT = new MockNFT();

    bool setUpInitialized;

    function setUp() public {
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

        //load Diamond with 100 ethers
        vm.deal(address(diamond), 100 ether);
    }

    function test_DeployDiamond() public view {
        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function test_LoanRequest() public {
        uint256 loanAmount = 5 ether;
        uint256 loanDuration = 60 * 60 * 24 * 30; //30 days

        //Mint token 1 to user
        IERC721(mockNFT).mint(borrower, tokenId);

        bytes memory _calldata = abi.encodeWithSelector(
            LendingFacet.requestLoan.selector, address(mockNFT), tokenId, loanAmount, loanDuration
        );

        vm.prank(borrower);
        (bool success,) = (address(diamond)).call(_calldata);
        assertTrue(success);
    }

    function test_Multiple_LoanRequest() public {
        uint256 loanAmount = 1 ether;
        uint256 loanDuration = 60 * 60 * 24 * 30; //30 days

        bytes memory _calldata = abi.encodeWithSelector(
            LendingFacet.requestLoan.selector, address(mockNFT), tokenId, loanAmount, loanDuration
        );

        vm.expectRevert(Collateral.NotOwner.selector);
        vm.prank(borrower);
        (bool success,) = (address(diamond)).call(_calldata);
        assertTrue(success);
    }

    function test_MaxLoanAmount() public {
        uint256 loanAmount = 15 ether;
        uint256 loanDuration = 60 * 60 * 24 * 30; //30 days

        bytes memory _calldata = abi.encodeWithSelector(
            LendingFacet.requestLoan.selector, address(mockNFT), tokenId, loanAmount, loanDuration
        );

        bytes4 errorSelector = bytes4(keccak256("MaxLoanAmountExceeded(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, 5 ether));
        vm.prank(borrower);
        (bool success,) = (address(diamond)).call(_calldata);
        assertTrue(success);
    }

    function test_Repayment() public {
        uint256 loanId = 1;
        uint256 repaymentAmount = 5.25 ether;

        //Fund borrower with repaymentAmount
        vm.deal(borrower, repaymentAmount);

        bytes memory _calldata = abi.encodeWithSelector(RepaymentFacet.repayLoan.selector, loanId);

        test_LoanRequest();
        vm.prank(borrower);
        (bool success,) = (address(diamond)).call{ value: repaymentAmount }(_calldata);
        assertTrue(success);
    }
}
