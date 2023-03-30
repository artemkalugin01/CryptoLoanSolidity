// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Creditor {
    bool isTrusted;
    int256 balance;
    mapping(uint => int) changes; // map timestamp to change in balance
}

contract TrustedCryptoLoan {
    int256 balance;
    address[] public creditors;
    mapping(address => Creditor) public creditorInfo;
    mapping(address => mapping(address => bool)) public hasVotedToAdd;

    constructor(address[] memory _creditors) {
        for (uint i = 0; i < _creditors.length; i++) {
            address creditor = _creditors[i];
            creditors.push(creditor);
            creditorInfo[creditor].isTrusted = true;
        }
    }

    function withdraw(uint amount) public {
        require(creditorInfo[msg.sender].isTrusted, "Only trusted creditors can withdraw");
        require(int(amount) >= balance, "Requested amount is higher than current balance");

        Creditor storage creditor = creditorInfo[msg.sender];
        creditor.changes[block.timestamp] = -int(amount);
        creditor.balance -= int(amount);
        balance -= int(amount);
        payable(msg.sender).transfer(amount);
    }

    function deposit(uint amount) public payable {
        require(creditorInfo[msg.sender].isTrusted, "Only trusted creditors can deposit");

        Creditor storage creditor = creditorInfo[msg.sender];
        creditor.changes[block.timestamp] = int(amount);
        creditor.balance += int(amount);
        balance += int(amount);
    }

    function approveNewCreditor(address newCreditor) public {
        require(!creditorInfo[newCreditor].isTrusted, "New creditor is already trusted");
        require(!hasVotedToAdd[newCreditor][msg.sender], "Creditor has already voted on this account");

        uint voteCount = 0;
        for (uint i = 0; i < creditors.length; i++) {
            address creditor = creditors[i];
            if (creditorInfo[creditor].isTrusted && hasVotedToAdd[newCreditor][creditor]) {
                voteCount++;
            }
        }

        if (voteCount == creditors.length) {
            creditors.push(newCreditor);
            creditorInfo[newCreditor].isTrusted = true;
        } else {
            hasVotedToAdd[newCreditor][msg.sender] = true;
        }
    }

    function getCreditorBalance(address creditorAddress) public view returns (int) {
        Creditor storage creditor = creditorInfo[creditorAddress];
        return int(creditor.balance);
    }   
}

