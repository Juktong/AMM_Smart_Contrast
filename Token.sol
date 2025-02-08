// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract DukeCompsciToken {
    uint256 private _totalSupply;
    string private _symbol;
    bool ongoingApprove;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) private lockedBalances;


    constructor(string memory symbol, uint256 initialSupply) {
        _symbol = symbol;
        _totalSupply = initialSupply;
        balances[msg.sender] = _totalSupply;
        ongoingApprove = false;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
    require(amount <= balances[msg.sender] - lockedBalances[msg.sender], "Not enough unlocked tokens");
    require(!ongoingApprove, "Another use is trying to transact, please wait!");
    
    allowances[msg.sender][spender] += amount;
    ongoingApprove = true;
    lockedBalances[msg.sender] += amount; // Lock the approved amount
    return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(amount <= balances[from], "Insufficient balance");
        require(amount <= allowances[from][msg.sender], "Allowance exceeded");

        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;

        lockedBalances[from] -= amount; // Unlock the used amount
        ongoingApprove = false;
        return true;
    }

    function transfer(address receiver, uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender] - lockedBalances[msg.sender], "Not enough unlocked tokens");
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        return true;
    }

    function balanceOf ( address account ) public view returns ( uint256 ){
        return balances[account];
    }

    function allowancesOf(address account, address spender) external view returns(uint256){
        return allowances[account][spender];
    }

    function undo_approve(address spender, uint256 amount) public {
        require(amount <= allowances[msg.sender][spender], "Amount exceeds allowance");
        require(amount <= balances[msg.sender], "Amount exceeds balance");require(amount <= lockedBalances[msg.sender], "Amount exceeds locked balance");
        allowances[msg.sender][spender] -= amount;
        lockedBalances[msg.sender] -= amount;
    }

}
