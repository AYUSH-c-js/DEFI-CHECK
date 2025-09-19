
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BurnOnSellToken {
    string public name = "BurnOnSell Token 7";
    string public symbol = "BOST7";
    uint8 public decimals = 18;

    uint256 public initialSupply = 1100000000 * 10**18; // 11 crore
    uint256 public targetSupply = 50000000 * 10**18;  // 5 crore
    uint256 public totalSupply;
    uint256 public totalBurned;

    uint256 public constant burnPercent = 3; // 3%
    address public liquidityPool; // <-- set this after adding liquidity

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event LiquidityPoolSet(address indexed pool);

    constructor() {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    function setLiquidityPool(address pool) external {
        require(liquidityPool == address(0), "Already set");
        liquidityPool = pool;
        emit LiquidityPoolSet(pool);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        return _transfer(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 currentAllowance = allowance[from][msg.sender];
        require(currentAllowance >= value, "Insufficient allowance");
        allowance[from][msg.sender] = currentAllowance - value;
        return _transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

function _transfer(address from, address to, uint256 value) internal returns (bool) {
    require(balanceOf[from] >= value, "Insufficient balance");

    uint256 burnAmount = 0;
    burnAmount = (value * burnPercent) / 100;

    // Burn only on sell (to liquidityPool) and above targetSupply
    if (to == liquidityPool && totalSupply > targetSupply) {
        burnAmount = (value * burnPercent) / 100;
        if (totalSupply - burnAmount < targetSupply) {
            burnAmount = totalSupply - targetSupply;
        }

        if (burnAmount > 0) {
            balanceOf[from] -= burnAmount;             // take burn tokens from sender
            balanceOf[address(0)] += burnAmount;       // send to null address
            totalSupply -= burnAmount;
            totalBurned += burnAmount;

            emit Burn(from, burnAmount);
            emit Transfer(from, address(0), burnAmount);
             // show burn in tx
        }
    }
emit Transfer(from, address(0), burnAmount);
    balanceOf[from] -= (value - burnAmount); // subtract rest
    balanceOf[to] += (value - burnAmount);

    emit Transfer(from, to, value - burnAmount);

    return true;
}

}
