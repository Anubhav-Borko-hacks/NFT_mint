pragma solidity ^0.8.10;

import "./multisig.sol";

contract Access{
    
    address mulAddress;

    function setAddress(address _mulAddress) external {
        address mulAddress = _mulAddress;
    }

    multisig mul =  multisig(mulAddress);

    function callSubmit() external view{
        mul.submit();
    }

    function callApprove() external view{
        mul.approve();
    }

    function callApproveCount() external view reutrns(uint){
        mul.ApproveCount();
    }

    function callExecute() external view{
        mul.execute();
    }

    function callRevoke() external view{
        mul.revoke();
    }
}