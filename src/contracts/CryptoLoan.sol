// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct LoanDetails {
    uint amount;
    uint duration;
    uint penalty;
    uint interestRate;
    uint timeElapsed;
    uint overdue;
    uint baseInterest;
    uint penaltyInterest;
}

contract CryptoLoan {
    mapping(address => uint) public balances;
    mapping(address => uint) public loanAmounts;
    mapping(address => uint) public loanTimes;
    mapping(address => uint) public loanInterestRates;
    mapping(address => uint) public loanDurations;
    mapping(address => uint) public loanPenalties;
    mapping(address => mapping(address => uint)) public allowedLoans;
    mapping(address => int) public reputationPerBorrower;
    uint public interestRate;
    uint public collateralRatio;
    
    constructor(uint _interestRate, uint _collateralRatio) {
        interestRate = _interestRate;
        collateralRatio = _collateralRatio;
    }
    
    function approve_lend(address potentialBorrower, uint amount, uint loanInterestRate) public payable {
        require(msg.value == amount, "Incorrect payment amount");
        require(loanInterestRate > 0, "Interest rate must be greater than zero");
        
        require(reputationPerBorrower[potentialBorrower] >= 0, "Borrower has negative reputation score");
        
        allowedLoans[msg.sender][potentialBorrower] += amount;
        loanInterestRates[potentialBorrower] = loanInterestRate;

    }

    function reset_approved_lend(address borrower) public payable{
        require(allowedLoans[msg.sender][borrower] !=0, "No approved loan funds found for this borrower");
        allowedLoans[msg.sender][borrower] = 0;

    }
    
    function borrow(uint amount, uint duration, uint penalty) public {
        require(amount <= (balances[msg.sender] * collateralRatio) / 100, "Insufficient collateral");
        require(loanAmounts[msg.sender] == 0, "Loan already taken");
        require(allowedLoans[msg.sender][msg.sender] >= amount, "You are not authorized to borrow this amount");
        
        balances[msg.sender] -= amount;
        loanAmounts[msg.sender] = amount;
        loanTimes[msg.sender] = block.timestamp;
        loanDurations[msg.sender] = duration;
        loanPenalties[msg.sender] = penalty;
        allowedLoans[msg.sender][msg.sender] -= amount;
    }
    
    function repay(uint amount) public payable {
        require(amount <= loanAmounts[msg.sender], "Cannot repay more than the loan amount");

        balances[msg.sender] += amount;
        loanAmounts[msg.sender] -= amount;
        if (block.timestamp > loanTimes[msg.sender] + loanDurations[msg.sender]) {
            reputationPerBorrower[msg.sender] = -1;
        }
        else if(loanAmounts[msg.sender] == 0) {
            reputationPerBorrower[msg.sender] += 1;
            loanInterestRates[msg.sender] = 0;
            loanDurations[msg.sender] = 0;
            loanPenalties[msg.sender] = 0;
        } 
    }
    
    function calculateInterest() public view returns(uint) {
        uint timeElapsed = block.timestamp - loanTimes[msg.sender];
        uint rate = loanInterestRates[msg.sender] > 0 ? loanInterestRates[msg.sender] : interestRate;
        uint duration = loanDurations[msg.sender];
        uint penalty = loanPenalties[msg.sender];
        uint overdue = timeElapsed > duration ? timeElapsed - duration : 0;

        uint baseInterest = (loanAmounts[msg.sender] * rate * timeElapsed) / (duration * 100);

        uint penaltyInterest = 0;
        if (overdue > 0) {
            penaltyInterest = overdue * penalty;
        }

        return baseInterest + penaltyInterest;
    }
    function isValidBorrower(address borrower) public view returns(bool) {
        return reputationPerBorrower[borrower] >= 0;
        
    }

    function getLoanDetails(address borrower) public view returns(LoanDetails memory) {
        require(loanAmounts[borrower] > 0, "No active loan");

        uint timeElapsed = block.timestamp - loanTimes[borrower];
        uint rate = loanInterestRates[borrower] > 0 ? loanInterestRates[borrower] : interestRate;
        uint duration = loanDurations[borrower];
        uint penalty = loanPenalties[borrower];
        uint overdue = timeElapsed > duration ? timeElapsed - duration : 0;

        uint baseInterest = (loanAmounts[borrower] * rate * timeElapsed) / (duration * 100);

        uint penaltyInterest = 0;
        if (overdue > 0) {
            penaltyInterest = overdue * penalty;
        }

        LoanDetails memory loan = LoanDetails({
            amount: loanAmounts[borrower],
            duration: duration,
            penalty: penalty,
            interestRate: rate,
            timeElapsed: timeElapsed,
            overdue: overdue,
            baseInterest: baseInterest,
            penaltyInterest: penaltyInterest
        });

        return loan;
    }
}
