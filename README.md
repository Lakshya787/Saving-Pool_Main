# 🏦 Savings Pool Smart Contract (Clarity)

A simple **Savings Pool** built in [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-language) for the Stacks blockchain.  
This contract allows users to **deposit STX tokens** into a shared pool and **withdraw their own contributions** (minus a small fee) at any time.  

---

## 📌 Features
- ✅ Deposit STX into a shared pool (with a minimum deposit requirement).  
- ✅ Withdraw STX from your contribution (fee applied).  
- ✅ Track total pool balance.  
- ✅ Track individual user contributions.  
- ✅ Contract owner is automatically set at deployment.  

---

## ⚙️ Data Definitions
- `contract-owner` → The deployer’s address (set on deployment).  
- `pool-balance` → Tracks the total balance of the pool.  
- `user-contributions` → A map of each user’s principal → their contribution.  

---

## 🚫 Error Codes
- `u100` → Unauthorized call.  
- `u101` → Invalid deposit/withdrawal amount.  
- `u102` → Insufficient funds for withdrawal.  
- `u103` → Transfer failed.  

---

## 💰 Constants
- **Minimum Deposit:** `u10000` (0.01 STX).  
- **Withdrawal Fee:** `u500` (0.0005 STX).  

---

## 🔑 Public Functions
### `deposit (amount uint)`  
- Deposit STX into the pool.  
- Updates user’s contribution and pool balance.  

### `withdraw (amount uint)`  
- Withdraw STX from the pool (must be greater than fee).  
- Deducts fee, updates balances, and transfers STX back to user.  

---

## 👀 Read-only Functions
### `get-pool-balance`  
- Returns total pool balance.  

### `get-user-contribution (user principal)`  
- Returns contribution amount of a given user.  

---

## 🛠️ Deployment
1. Install [Clarinet](https://github.com/hirosystems/clarinet).  
2. Create a new Clarinet project:  
   ```bash
   clarinet new savings-pool
   cd savings-pool
