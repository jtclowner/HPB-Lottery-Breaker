pragma solidity ^0.8.4;

/**
@title  Ownable
@dev    Implements ownership functionality.
*/
abstract contract Ownable {
    address internal __owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    /**
    @dev Ownable constructor.
    */
    constructor() {
        __owner = msg.sender;
    }

    /**
    @dev Check the ownership of the recipient address.
    @param _recipient Address to check.
    @return Boolean
    */
    function checkOwnership(address _recipient) public view returns (bool) {
        return __owner == _recipient;
    }

    modifier RequireOwnership() {
        require(
            __owner == msg.sender,
            "Current recipient does not contain ownership attribution."
        );
        _;
    }

    modifier RequireOwnershipOr(address _orAddress) {
        require(
            __owner == msg.sender || msg.sender == _orAddress,
            "Current recipient does not contain required attribution."
        );
        _;
    }

    modifier RequireOwnershipOrCondition(bool _condition) {
        require(
            __owner == msg.sender || _condition,
            "Ownership or special condition has not been fullfilled."
        );
        _;
    }

    /**
    @dev Grant ownership to the recipient and removes own ownership.
    @param _to Recipient address.
    #req Executed by owner.
    #req New owner is not null.
    */
    function transferOwnership(address _to) public RequireOwnership {
        require(
            _to != address(0),
            "Ownership cannot be enabled for null address."
        );
        __owner = _to;

        emit OwnershipTransferred(msg.sender, _to);
    }
}
