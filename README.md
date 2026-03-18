# Home Assessment

## Overview
This repository contains my solution to the smart contract home assessment.

The objective was to update and implement logic in `Token.sol` such that all provided test cases pass successfully.

---

## Mental Model & Approach

I structured the solution around three core functionalities:

### 1. Mint

Minting allows users to receive WETH tokens equivalent to the ETH sent.

#### Conditions handled:
- Tokens are minted when ETH is sent
- Supports direct transfers after minting
- Supports indirect transfers via contract logic

---

### 2. Burn

Burning allows users to redeem ETH by burning their WETH tokens.

#### Conditions handled:
- Burns tokens from `msg.sender`
- Sends equivalent ETH to the destination address
- Maintains correct balance updates

---

### 3. Dividend System

Dividend represents distribution of ETH proportional to token holdings.

#### Conditions handled:
- Records dividend deposits
- Prevents empty dividend distribution
- Tracks holders during:
  - Minting
  - Burning
  - Transfers
- Ensures proportional distribution based on total supply
- Supports:
  - Compounding payouts
  - Partial withdrawals
  - Withdrawals even after user exits (balance becomes 0)

---

## Internal Helper

### `_updateHolder(address user)`

Maintains the state of token holders.

#### Responsibilities:
- Adds new holders
- Tracks holder status
- Removes holders when balance becomes zero

---

##  Tech Stack

- Solidity
- Hardhat
- Chai (testing)

---

## How to Run

```bash
npm install
npx hardhat test


