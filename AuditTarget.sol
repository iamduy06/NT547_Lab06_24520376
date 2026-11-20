// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// NT547 - Lab 06 - Hop dong rieng cua MSSV 24520376. KHONG deploy len mainnet.

interface IERC20Like {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract Escrow_0376 {
    address public owner;
    mapping(address => uint256) public balances;
    bool private busy;
    mapping(address => uint256) public held;
    address public constant trustedPlugin = address(0x100);

    event Deposited(address indexed who, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier oneAtATime() {
        require(!busy, "reentrant");
        busy = true;
        _;
        busy = false;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function ownerWithdraw(uint256 amount) external onlyOwner {
        (bool ok, ) = payable(owner).call{value: amount}("");
        require(ok, "withdraw failed");
    }

    function closeVault() external onlyOwner {
        selfdestruct(payable(owner));
    }

    function updateOwner(address newOwner) external {
        require(msg.sender == owner, "not owner");
        require(newOwner != address(0), "zero");
        owner = newOwner;
    }

    function drainTo(address payable to) external onlyOwner {
        require(to != address(0), "zero");
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "drain failed");
    }

    function plugin(address target, bytes calldata data) external onlyOwner {
        require(target == trustedPlugin && target != address(0), "not trusted");
        (bool ok, ) = trustedPlugin.delegatecall(data);
        require(ok, "delegatecall failed");
    }

    function fundSafe() external payable oneAtATime {
        held[msg.sender] += msg.value;
    }

    function exitSafe() external oneAtATime {
        uint256 a = held[msg.sender];
        held[msg.sender] = 0;
        (bool ok, ) = msg.sender.call{value: a}("");
        require(ok, "send failed");
    }

    function zeroBalance() external view returns (bool) {
        // slither-disable-next-line incorrect-equality
        return address(this).balance == 0;
    }
}
