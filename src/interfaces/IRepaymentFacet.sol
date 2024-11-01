// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IRepaymentFacet {
    function repayLoan(uint256 loanId) external payable;
}
