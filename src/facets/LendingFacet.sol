// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { console } from "../../lib/forge-std/src/console.sol";
import { Collateral } from "./Collateral.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract LendingFacet is Collateral {
    error NFTIsCollateralized();
    error MaxLoanAmountExceeded(uint256 maxLoanAmount);
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
    function requestLoan(address nftAddress, uint256 tokenId, uint256 loanAmount, uint256 loanDuration)
        external
        payable
    {
        LibDiamond.LoanStorage storage ls = LibDiamond.loanStorage();
        require(!ls.collateralizedNFTs[nftAddress][tokenId], NFTIsCollateralized());

        uint256 nftValue = _getNFTValue(nftAddress, tokenId);
        uint256 maxLoanAmount = (nftValue * ls.ltvRatio) / 100;
        require(loanAmount <= maxLoanAmount, MaxLoanAmountExceeded(maxLoanAmount));

        addCollateral(nftAddress, tokenId);

        ls.loanCounter++;
        ls.loans[ls.loanCounter] = LibDiamond.Loan({
            borrower: msg.sender,
            lender: address(this),
            nftAddress: nftAddress,
            tokenId: tokenId,
            loanAmount: loanAmount,
            interestRate: ls.interestRate,
            dueDate: block.timestamp + loanDuration,
            repaid: false
        });

        // Transfer the loan amount to the borrower
        payable(msg.sender).transfer(loanAmount);

        emit LoanRequested(
            ls.loanCounter, msg.sender, address(this), loanAmount, ls.interestRate, block.timestamp + loanDuration
        );
    }

    /// @notice Update the platform-wide interest rate for loans
    /// @param newInterestRate The new interest rate in basis points (e.g., 500 = 5%)
    function updateInterestRate(uint256 newInterestRate) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.LoanStorage storage ls = LibDiamond.loanStorage();
        ls.interestRate = newInterestRate;
        emit InterestRateUpdated(newInterestRate);
    }

    /// @notice Placeholder function for NFT valuation
    /// @dev Should be replace with a call to a marketplace API, oracle, or other appraisal model
    /// @param nftAddress The address of the NFT contract
    /// @param tokenId The token ID of the NFT
    function _getNFTValue(address nftAddress, uint256 tokenId) private pure returns (uint256) {
        // Placeholder: In production, replace with actual valuation logic
        // E.g., query from Chainlink oracle, floor price, or use peer-to-peer negotiation.
        console.log(nftAddress, tokenId);
        return 10 ether; // Dummy value
    }

    /// @notice function to get the amout of loan for NFT
    /// @param nftAddress The address of the NFT contract
    /// @param tokenId The token ID of the NFT
    function getNFTLoanWorth(address nftAddress, uint256 tokenId) external view returns (uint256 maxLoanAmount) {
        uint256 nftValue = _getNFTValue(nftAddress, tokenId);
        LibDiamond.LoanStorage storage ls = LibDiamond.loanStorage();
        maxLoanAmount = (nftValue * ls.ltvRatio) / 100;
    }
}
