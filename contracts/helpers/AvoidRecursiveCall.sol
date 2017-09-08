pragma solidity ^0.4.2;


contract AvoidRecursiveCall {

    bool avoidRecursiveCallFlag = false;

    modifier avoidRecursiveCall() {
        require(!avoidRecursiveCallFlag);
        avoidRecursiveCallFlag = true;
        _;
        avoidRecursiveCallFlag = false;
    }

}