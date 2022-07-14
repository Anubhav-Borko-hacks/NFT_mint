pragma solidity ^0.8.10;

contract MultisigWallet{
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
    }
    
    address[] public owners; //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    
    mapping(address => bool) public isOwner; //to check if the addresses are the owners afterwards

    uint public minAuthorization; //check for error in this line

    Transaction[] public transactions; //to store transactions in a struct

    mapping(uint => mapping(address => bool)) public approved; //to check how many addresses approve of the transaction

    modifier onlyOwner(){
        require(isOwner[msg.sender],"Not Owner");
        _;
    }

    modifier txExists(uint _txId){
        require(_txId < transactions.length,"Transaction does not exist");
        _;
    }
    
    modifier notApproved(uint _txId){
        require(!approved[_txId][msg.sender],"Transaction already approved");
        _; //approved mapping takes uint and address to track transactions
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "Transaction already executed");
        _;
    }
    constructor(address[] memory _owners, uint _minAuth){
        require(_owners.length > 0,"No Owners");
        require(_minAuth >= minAuthorization && _minAuth <= _owners.length,"Not Authorized !");

        for(uint i;i< _owners.length;i++){ //to check if owner and address[0] are not same and they are unique
            address owner= _owners[i];
            require(owner != address(0), "Not owner");
            require(!isOwner[owner],"Owners already in the list");//to make sure owner is not there in the list yet...

            isOwner[owner] = true;
            owners.push(owner); //pushing address as owner to the array 'owners'

        }
         minAuthorization=_minAuth;  

    }

    receive() external payable { 
        emit Deposit(msg.sender,msg.value); 
    }
    
    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner{
        transactions.push(Transaction({
            to:_to,
            value:_value,
            data:_data,
            executed: false
        }));
        emit Submit(transactions.length - 1);
    }

    function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId){ 
        approved[_txId][msg.sender]=true;
        emit Approve(msg.sender,_txId);
    }

    function ApproveCount(uint _txId) private view returns(uint count){
        for(uint i;i<owners.length;i++){
            if(approved[_txId][owners[i]]){
                count+=1;
            }
        }
        // uint min = uint256(int256(count))/uint256(int256(owners.length));
        // return min;
    }

    function execute(uint _txId) external txExists(_txId) notExecuted(_txId){
        require(ApproveCount(_txId)>=minAuthorization,"approvals are not more than 60%");
        Transaction storage transaction = transactions[_txId];

        transaction.executed = true;

        (bool success, )=transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success,"Transaction failed");

        emit Execute(_txId);
    }

    function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
        require(approved[_txId][msg.sender],"Transaction not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender,_txId);
    }
}