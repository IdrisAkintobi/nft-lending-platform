# NFT-Collateralized Lending Platform

This project implements a decentralized lending platform that utilizes NFTs as collateral for loans, based on the [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535). This allows the platform to be modular and upgradeable, separating functionalities into facets for better organization and efficiency.

## Table of Contents

- [Introduction](#introduction)
- [Overview of Contract Structure](#overview-of-contract-structure)
- [Contracts](#contracts)
  - [LendingFacet](#lendingfacet)
  - [RepaymentFacet](#repaymentfacet)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Functions](#functions)
- [Events](#events)
- [Testing](#testing)

---

## Introduction

This smart contract system allows users to collateralize NFTs and take out loans in exchange. Loans are issued by locking the NFT within the contract. Interest rates, loan amounts, and durations are configurable, with each loan tracked individually.

### Key Features

1. **NFT-Collateralized Loans**: Borrowers use NFTs as collateral to secure loans.
2. **Interest Rate Management**: Admins can adjust platform-wide interest rates.
3. **Modular Design**: Built on the EIP-2535 standard, enabling easy upgrades.
4. **Safe Loan Repayment and Collateral Return**: Borrowers can repay loans with interest, at which point their NFT collateral is returned.

---

## Overview of Contract Structure

The system is designed with multiple facets in a diamond pattern, where each facet represents a different function:

1. **Diamond Cut Facet**: Manages adding, replacing, or removing functions in the diamond.
2. **Diamond Loupe Facet**: Provides information about the functions and facets in the diamond.
3. **LendingFacet**: Handles loan requests, NFT collateralization, and interest rate updates.
4. **RepaymentFacet**: Manages loan repayments, collateral returns, and loan status updates.

---

## Contracts

### LendingFacet

The **LendingFacet** handles requests for loans by locking up an NFT as collateral. It checks whether the requested loan amount falls within the maximum allowed value (based on the Loan-to-Value ratio).

- **Function**: `requestLoan(address nftAddress, uint256 tokenId, uint256 loanAmount, uint256 loanDuration)`
- **Function**: `updateInterestRate(uint256 newInterestRate)`
- **Function**: `_getNFTValue(address nftAddress, uint256 tokenId)` (internal placeholder)

### RepaymentFacet

The **RepaymentFacet** enables borrowers to repay their loans and receive their NFT back upon full repayment. It verifies the repayment amount, checks the loan's repayment status, and transfers ownership of the NFT back to the borrower if the loan is repaid.

- **Function**: `repayLoan(uint256 loanId)`
- **Function**: `viewLoan(uint256 loanId)`

---

## Getting Started

### Prerequisites

- [Foundry](https://github.com/foundry-rs/foundry) for Solidity testing

### Installation

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   ```

2. **Compile the contracts**:
   ```bash
   forge build
   ```

---

## Functions

### DIAGRAM

![NFT-Lending-Platform.png](https://github.com/user-attachments/assets/e3f12508-6c18-420f-844b-a4b796a6e419)


### LendingFacet

1. **requestLoan**

   - **Description**: Requests a loan by collateralizing an NFT. Checks that the loan amount does not exceed the maximum allowable amount based on the NFT's valuation.
   - **Parameters**:
     - `nftAddress`: Address of the NFT contract.
     - `tokenId`: ID of the NFT to be used as collateral.
     - `loanAmount`: Requested loan amount.
     - `loanDuration`: Duration of the loan in seconds.

2. **updateInterestRate**

   - **Description**: Allows the contract owner to update the platform-wide interest rate.
   - **Parameters**:
     - `newInterestRate`: The new interest rate in basis points.

3. **getNFTLoanWorth**
   - **Description**: Calculates the maximum loan amount based on the NFT’s value and the loan-to-value (LTV) ratio.
   - **Parameters**:
     - `nftAddress`: Address of the NFT contract.
     - `tokenId`: ID of the NFT.

### RepaymentFacet

1. **repayLoan**

   - **Description**: Allows the borrower to repay a loan with interest, which returns the NFT collateral to them.
   - **Parameters**:
     - `loanId`: ID of the loan.

2. **viewLoan**
   - **Description**: Allows the borrower to view their loan details.
   - **Parameters**:
     - `loanId`: ID of the loan.

---

## Events

1. **LoanRequested**

   - Emitted when a new loan is requested.
   - **Parameters**: `loanId`, `borrower`, `lender`, `loanAmount`, `interestRate`, `dueDate`.

2. **InterestRateUpdated**

   - Emitted when the platform-wide interest rate is updated.
   - **Parameters**: `newInterestRate`.

3. **LoanRepaid**
   - Emitted when a loan is successfully repaid.
   - **Parameters**: `loanId`, `borrower`, `amountPaid`.

---

## Testing

The test suite includes various scenarios, such as single and multiple loan requests, repayment processes, and interest rate updates.

To run the tests:

```bash
forge test
```

### Test Cases

1. **test_DeployDiamond**: Ensures that the diamond deployment and facets integration are successful.
2. **test_LoanRequest**: Verifies that a loan request is successfully processed.
3. **test_Multiple_LoanRequest**: Tests the behavior of attempting to collateralize the same NFT twice.
4. **test_MaxLoanAmount**: Checks that the maximum loan amount is enforced based on the NFT's value.
5. **test_Repayment**: Ensures that the loan repayment process works as expected, including returning the NFT to the borrower.

---

## License

This project is licensed under the [MIT License](LICENSE).
