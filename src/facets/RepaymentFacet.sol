// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Collateral } from "../contracts/Collateral.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract RepaymentFacet is Collateral {
    error InsufficientRepaymentAmount(uint256 totalRepayment);
    error OnlyBorrowerCanRepay();
    error YouCanOnlyViewYourLoan();
    error LoanAlreadyRepaid();

    event LoanRepaid(uint256 loanId, address indexed borrower, uint256 amountPaid);

    /// @notice Allows the borrower to repay the loan with interest
    /// @param loanId The ID of the loan to repay
    function repayLoan(uint256 loanId) external payable {
        LibDiamond.LoanStorage storage ls = LibDiamond.loanStorage();

        require(msg.sender == ls.loans[loanId].borrower, OnlyBorrowerCanRepay());
        require(!ls.loans[loanId].repaid, LoanAlreadyRepaid());

        uint256 interestAmount = (ls.loans[loanId].loanAmount * ls.loans[loanId].interestRate) / 10000;
        uint256 totalRepayment = ls.loans[loanId].loanAmount + interestAmount;

        require(msg.value >= totalRepayment, InsufficientRepaymentAmount(totalRepayment));

        ls.loans[loanId].repaid = true; // Directly modifies storage

        // Return excess payment if overpaid
        if (msg.value > totalRepayment) {
            payable(msg.sender).transfer(msg.value - totalRepayment);
        }

        // Transfer the NFT collateral back to the borrower
        removeCollateral(ls.loans[loanId].nftAddress, ls.loans[loanId].tokenId);

        emit LoanRepaid(loanId, ls.loans[loanId].borrower, totalRepayment);
    }

    /// @notice Allows the borrower to view their loan
    /// @param loanId The ID of the loan to repay
    function viewLoan(uint256 loanId) external view returns (LibDiamond.Loan memory loan) {
        LibDiamond.LoanStorage storage ls = LibDiamond.loanStorage();
        loan = ls.loans[loanId];
        require(msg.sender == loan.borrower, YouCanOnlyViewYourLoan());
    }
}
