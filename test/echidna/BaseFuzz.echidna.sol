pragma solidity ^0.8.20;

interface IHevm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function label(address, string calldata) external;
}

contract BaseFuzz {
    IHevm internal hevm = IHevm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    address[3] internal actors = [makeAddr("Actor 1"), makeAddr("Actor 2"), makeAddr("Actor 3")];
    uint256 private randNonce = 0;

    function makeAddr(string memory label) internal returns (address) {
        address addr = address(uint160(uint256(keccak256(bytes(label)))));
        hevm.label(addr, label);
        return addr;
    }

    modifier useRandomActor() {
        uint256 pseudoRandomIndex = uint256(keccak256(abi.encodePacked(++randNonce))) % actors.length;
        hevm.startPrank(actors[pseudoRandomIndex]);
        _;
        hevm.stopPrank();
    }
}
