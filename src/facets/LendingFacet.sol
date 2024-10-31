// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {console} from "../../lib/forge-std/src/console.sol";
import {CollateralFacet} from "./CollateralFacet.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract LendingFacet {
    error NFTNotCollateralized();
    error InsufficientLoanAmountProvided();
    error NotContractOwner();

    event LoanRequested(
        uint256 indexed loanId,
        address indexed borrower,
        address indexed lender,
        uint256 loanAmount,
        uint256 interestRate,
        uint256 dueDate
    );
    event InterestRateUpdated(uint256 newInterestRate);

    /// @notice Request and fund a loan by locking up an NFT as collateral
    /// @param nftAddress The address of the NFT contract
    /// @param tokenId The token ID of the NFT
    /// @param loanDuration The duration of the loan
    function requestLoan(
        address nftAddress,
        uint256 tokenId,
        uint256 loanDuration
    ) external payable {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(
            ds.collateralizedNFTs[nftAddress][tokenId],
            NFTNotCollateralized()
        );

        uint256 nftValue = getNFTValue(nftAddress, tokenId);
        uint256 maxLoanAmount = (nftValue * ds.ltvRatio) / 100;
        require(msg.value >= maxLoanAmount, InsufficientLoanAmountProvided());

        ds.loanCounter++;
        ds.loans[ds.loanCounter] = LibDiamond.Loan({
            borrower: msg.sender,
            lender: address(this),
            nftAddress: nftAddress,
            tokenId: tokenId,
            loanAmount: maxLoanAmount,
            interestRate: ds.interestRate,
            dueDate: block.timestamp + loanDuration,
            repaid: false
        });

        // Transfer the loan amount to the borrower
        payable(msg.sender).transfer(maxLoanAmount);

        emit LoanRequested(
            ds.loanCounter,
            msg.sender,
            address(this),
            maxLoanAmount,
            ds.interestRate,
            block.timestamp + loanDuration
        );
    }

    /// @notice Update the platform-wide interest rate for loans
    /// @param newInterestRate The new interest rate in basis points (e.g., 500 = 5%)
    function updateInterestRate(uint256 newInterestRate) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.contractOwner == msg.sender, NotContractOwner());
        ds.interestRate = newInterestRate;
        emit InterestRateUpdated(newInterestRate);
    }

    /// @notice Placeholder function for NFT valuation
    /// @dev Should be replace with a call to a marketplace API, oracle, or other appraisal model
    function getNFTValue(
        address nftAddress,
        uint256 tokenId
    ) internal pure returns (uint256) {
        // Placeholder: In production, replace with actual valuation logic
        // E.g., query from Chainlink oracle, floor price, or use peer-to-peer negotiation.
        console.log(nftAddress, tokenId);
        return 10 ether; // Dummy value
    }
}
