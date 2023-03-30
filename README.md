# CryptoLoan project

## Structure

Repository contains 2 smart contracts - **CryptoLoan** & **TrustedCryptoLoan**

## Generic idea

**TrustedCryptoLoan** contract can be used on its own and contains all needed functionality to perform operation.
General idea to use both contracts together:

![Structure](static/trusted_loans_structure.jpg?raw=true "Title")

A set of creditors form a shared account (**TrustedCryptoLoan**) which they have full control of.
Using funds from this account they can loan any amounts of funds separately from each other on their own terms.

A set of "trusted creditors" can also add a new that will gain full access of shared account if all existing agree on that.

## CryptoLoan

- **approve_lend** - Approve lending amount of funds
- **reset_approved_lend** - reset existing approved amounts for specific account
- **borrow** - borrow amount of funds
- **repay** - Return borrowed funds partly or in full
- **calculateInterest** - calculate amount of interest on specific loan
- **isValidBorrower** - check if borrower is valid (uses internal reputation based on previous loans)
- **getLoanDetails** - Get details of specific loan - **LoanDetails** structure

## TrustedCryptoLoan

- **withdraw** - withdraw any amount from shared account
- **deposit** - deposit any amount to shared account
- **approve_new_trusted_creditor** - "vote" on adding a new "trusted creditor" to shared account
- **getCreditorInfo** - "vote" on adding a new "trusted creditor" to shared account
- **getCreditorBalance** - get internal balance for specific creditor
