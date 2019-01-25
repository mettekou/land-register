pragma solidity ^0.5.3;

contract Register {
    
    modifier only(address by) {
        require(msg.sender == by);
        _;
    }
    
    event Sold(address from, address to, uint code, uint price);
    
    struct Land {
        uint[] xBorders;
        uint[] yBorders;
        uint size;
        uint value;
        address owner;
    }
    
    uint current;
    mapping (uint => Land) lands;
    address payable notary;
    
    constructor() public {
        current = 0;
        notary = msg.sender;
    }
    
    function destroy() public only(notary) {
        selfdestruct(notary);
    }
    
    function createLand(uint[] memory xBorders, uint[] memory yBorders, uint size, uint value, address owner) public only(notary) returns (uint) {
        lands[current] = Land({xBorders: xBorders, yBorders: yBorders, size: size, value: value, owner: owner});
        return current++;
    }
    
    function sell(uint code, address to, uint price) public only(lands[code].owner) {
        // Do not permit an owner to sell a land to himself to conserve gas.
        // Note that this transaction would be idempotent because we only transfer ownership, not funds.
        require(to != lands[code].owner);
        lands[code].owner = to;
        // Arguably the value does not change here, but we assume implementing another means of revaluation is outside the scope of the assigment.
        lands[code].value = price;
        emit Sold(msg.sender, to, code, price);
    }
}