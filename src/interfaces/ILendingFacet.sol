// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILendingFacet {
    function requestLoan(
        address nftAddress,
        uint256 tokenId,
        uint256 loanAmount,
        uint256 loanDuration
    ) external payable;

    function updateInterestRate(uint256 newInterestRate) external;

    function getNFTLoanWorth(
        address nftAddress,
        uint256 tokenId
    ) external view returns (uint256 maxLoanAmount);
}
