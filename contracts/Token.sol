// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.7.0;

import "./IERC20.sol";
import "./IMintableToken.sol";
import "./IDividends.sol";
import "./SafeMath.sol";

contract Token is IERC20, IMintableToken, IDividends {
    // ------------------------------------------ //
    // ----- BEGIN: DO NOT EDIT THIS SECTION ---- //
    // ------------------------------------------ //
    using SafeMath for uint256;
    uint256 public totalSupply;
    uint256 public decimals = 18;
    string public name = "Test token";
    string public symbol = "TEST";
    mapping(address => uint256) public balanceOf;
    // ------------------------------------------ //
    // ----- END: DO NOT EDIT THIS SECTION ------ //
    // ------------------------------------------ //

    mapping(address => mapping(address => uint256)) public allowances;

    mapping(address => bool) internal isHolder;
    address[] internal holders;

    mapping(address => uint256) internal holderIndex;

    mapping(address => uint256) internal dividends;
    // IERC20

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return allowances[owner][spender];
    }

    function transfer(
        address to,
        uint256 value
    ) external override returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(to != address(0), "Invalid address");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
        balanceOf[to] = balanceOf[to].add(value);

        _updateHolder(msg.sender);
        _updateHolder(to);

        return true;
    }

    function approve(
        address spender,
        uint256 value
    ) external override returns (bool) {
        require(spender != address(0), "Invalid address");

        allowances[msg.sender][spender] = value;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowances[from][msg.sender] >= value, "Allowance exceeded");
        require(to != address(0), "Invalid address");

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);

        allowances[from][msg.sender] = allowances[from][msg.sender].sub(value);

        _updateHolder(from);
        _updateHolder(to);

        return true;
    }

    // IMintableToken

    function mint() external payable override {
        require(msg.value > 0, "Caller's msg.value has to be greater than 0");
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        _updateHolder(msg.sender);
        // revert();
    }

    function burn(address payable dest) external override {
        require(balanceOf[msg.sender] > 0, "Caller has no tokens to burn");
        uint256 burnAmount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        totalSupply = totalSupply.sub(burnAmount);

        _updateHolder(msg.sender);

        (bool success, ) = dest.call{value: burnAmount}("");
        require(success, "ETH transfer failed");
    }

    // IDividends

    function getNumTokenHolders() external view override returns (uint256) {
        return holders.length;
    }

    function getTokenHolder(
        uint256 index
    ) external view override returns (address) {
        require(index >= 1 && index <= holders.length, "Index out of bounds");

        return holders[index - 1];
    }

    function recordDividend() external payable override {
        require(msg.value > 0, "No ETH sent");

        for (uint256 i = 0; i < holders.length; i++) {
            address user = holders[i];

            uint256 share = msg.value.mul(balanceOf[user]).div(totalSupply);

            dividends[user] = dividends[user].add(share);
        }
    }

    function getWithdrawableDividend(
        address payee
    ) external view override returns (uint256) {
        return dividends[payee];
    }

    function withdrawDividend(address payable dest) external override {
        uint256 amount = dividends[msg.sender];
        require(amount > 0, "No dividend");

        dividends[msg.sender] = 0;

        (bool success, ) = dest.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // Helper functions for updating holders
    function _updateHolder(address user) internal {
        if (balanceOf[user] > 0) {
            if (!isHolder[user]) {
                isHolder[user] = true;
                holderIndex[user] = holders.length;
                holders.push(user);
            }
        } else {
            if (isHolder[user]) {
                uint256 index = holderIndex[user];
                uint256 lastIndex = holders.length - 1;
                address last = holders[lastIndex];

                if (index != lastIndex) {
                    holders[index] = last;
                    holderIndex[last] = index;
                }

                holders.pop();
                isHolder[user] = false;
                delete holderIndex[user];
            }
        }
    }
}
