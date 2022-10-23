

//What this contract does
//Creates a pool of specified token balances (mapping) transfered
//Each token balance will be assigned an ideal ratio of the total contract balance at deployment
//A specific rebalancing time will be asigned at deployment (example: every minute, 3 minutes, day etc)
//Allows owner to transfer balances to any of the tokens available in the pool
//Allows anyone to view the balance of each token
//Allows owner to withdraw all the balances to their wallet
//Allows owner to withdraw soome of the balance/s to their wallet
//Checks the price of each token via Chainlink
//Runs a cron job every specific time to check if the ratio asigned at deploymennt still holds for the dollar values of all tokens
//If the ratio changed are not equal to the previously asigned ractio, and if the profit made > the gas cost, the contract will sell and buy tokens to rebalance the pool 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract Vault {

//mapp token address to their ratio of the vault (total ratio of all tokens must be 100%)
    mapping(IERC20  => uint) public tokenRations;
    mapping(IERC20  => uint) public tokenAmmounts;

//set the contract owner to deposit and withdraw
    address payable contractOwner = payable(msg.sender);
//specify the last amount of WETH deposited
    uint public lastWETHreceived;
    uint public timesWETHreceived;
    uint public allWETHreceived;




//take the number of tokens, their address, and respective ratios and input them to the tokens mapping
//only initiate the contract if number of tokens less than 8, and number of tokens is equal to the number of addresses and ratios
//populate the tokens mapping with the address of each token and its ratio
    constructor(uint _noOfTokens, IERC20[] memory _toekenAddresses, uint[] memory _ratios) {
        if (_noOfTokens <= 8 && _noOfTokens == _toekenAddresses.length && _noOfTokens == _ratios.length){
            for (uint i = 0; i < _noOfTokens; i++) {
                tokenRations[_toekenAddresses[i]] = _ratios[i];
                tokenAmmounts[_toekenAddresses[i]] = 0;
            }
        }
    }


//deposit WETH to contract
    function depositWETH() public payable{
        lastWETHreceived = msg.value;
        allWETHreceived += msg.value;
        timesWETHreceived += msg.value;
    }

//Withdraw tokens
    function withdrawToken(IERC20 _tokenAddress, uint _withdrawAmount) public { 
        require(msg.sender == contractOwner, "You are not the owner of the vault");
        require(tokenAmmounts[_tokenAddress] > 0); // make sure the contract has balance of the requested token.
        require(tokenAmmounts[_tokenAddress] >= _withdrawAmount); // make sure the contract has balance of the requested token.
        _tokenAddress.transfer(contractOwner, _withdrawAmount);
    }

//Contract owner to transfer tokens to another address
    function withdrawTokenTo(IERC20 _tokenAddress, uint _withdrawAmount, address _receiver) public{
        require(msg.sender == contractOwner, "You are not the owner of the vault");
        require(tokenAmmounts[_tokenAddress] > 0); // make sure the contract has balance of the requested token.
        require(tokenAmmounts[_tokenAddress] >= _withdrawAmount); // make sure the contract has balance of the requested token.
        _tokenAddress.transfer(_receiver, _withdrawAmount);
    }


// function withdrawTokenTo(address _tokenAddress, uint _withdrawAmount) public{
//             if(msg.sender == contractOwner){
//             _to.transfer(getContractBalance());
//             }else{
//                 whoIsPlaying = msg.sender;
//             }
//         }


//         function getContractBalance() public view returns(uint){
//             return address(this).balance;
//         }

//         function withdrawAll() public payable{
//             contractOwner.transfer(getContractBalance());
//         }

       



    //uint public totalSupply;
    //mapping(address => uint) public balanceOf;


    // function _mint(address _to, uint _shares) private {
    //     totalSupply += _shares;
    //     balanceOf[_to] += _shares;
    // }

    // function _burn(address _from, uint _shares) private {
    //     totalSupply -= _shares;
    //     balanceOf[_from] -= _shares;
    // }

    // function deposit(uint _amount) external {
    //     /*
    //     a = amount
    //     B = balance of token before deposit
    //     T = total supply
    //     s = shares to mint

    //     (T + s) / T = (a + B) / B 

    //     s = aT / B
    //     */
    //     uint shares;
    //     if (totalSupply == 0) {
    //         shares = _amount;
    //     } else {
    //         shares = (_amount * totalSupply) / token.balanceOf(address(this));
    //     }

    //     _mint(msg.sender, shares);
    //     token.transferFrom(msg.sender, address(this), _amount);
    // }

    // function withdraw(uint _shares) external {
    //     /*
    //     a = amount
    //     B = balance of token before withdraw
    //     T = total supply
    //     s = shares to burn

    //     (T - s) / T = (B - a) / B 

    //     a = sB / T
    //     */
    //     uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;
    //     _burn(msg.sender, _shares);
    //     token.transfer(msg.sender, amount);
    // }
}

