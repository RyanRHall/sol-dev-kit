pragma solidity ^0.8.20;

interface IHevm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function label(address, string calldata) external;
}

contract BaseFuzz {
    IHevm internal hevm = IHevm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    address[3] internal users = [makeAddr("User 1"), makeAddr("User 2"), makeAddr("User 3")];
    uint256 private randNonce = 0;
    address private currentUser;

    function makeAddr(string memory label) internal returns (address) {
        address addr = address(uint160(uint256(keccak256(bytes(label)))));
        hevm.label(addr, label);
        return addr;
    }

    function getCurrentUser() internal view returns (address) {
        return currentUser;
    }

    modifier prankRandomUser() {
        uint256 pseudoRandomIndex = uint256(keccak256(abi.encodePacked(++randNonce))) % users.length;
        currentUser = users[pseudoRandomIndex];
        hevm.startPrank(users[pseudoRandomIndex]);
        _;
        hevm.stopPrank();
        currentUser = address(0);
    }
}
