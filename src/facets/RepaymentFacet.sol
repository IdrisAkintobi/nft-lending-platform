// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC721} from "../interfaces/IERC721.sol";
import {Collateral} from "./Collateral.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract RepaymentFacet is Collateral {
    error InsufficientRepaymentAmount(uint256 totalRepayment);
    error OnlyBorrowerCanRepay();
    error LoanAlreadyRepaid();

    event LoanRepaid(
        uint256 loanId,
        address indexed borrower,
        uint256 amountPaid
    );

    /// @notice Allows the borrower to repay the loan with interest
    /// @param loanId The ID of the loan to repay
    function repayLoan(uint256 loanId) external payable {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        LibDiamond.Loan memory loan = ds.loans[loanId];

        require(msg.sender == loan.borrower, OnlyBorrowerCanRepay());
        require(!loan.repaid, LoanAlreadyRepaid());

        uint256 interestAmount = (loan.loanAmount * loan.interestRate) / 10000; // Interest calculation in basis points
        uint256 totalRepayment = loan.loanAmount + interestAmount;

        require(
            msg.value >= totalRepayment,
            InsufficientRepaymentAmount(totalRepayment)
        );

        // Mark the loan as repaid in the LendingFacet
        loan.repaid = true;

        // Transfer the NFT collateral back to the borrower
        removeCollateral(loan.nftAddress, loan.tokenId);

        emit LoanRepaid(loanId, loan.borrower, totalRepayment);
    }
}
