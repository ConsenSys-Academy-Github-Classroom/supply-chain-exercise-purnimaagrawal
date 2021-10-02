// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {
    address public owner; 

    uint256 public skuCount;

    mapping(uint256 => Item) public items;

    enum State {ForSale, Sold, Shipped, Received}

    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }

    /*
  /* 
    /*
     * Events
     */

    event LogForSale(uint256 indexed sku);

    event LogSold(uint256 indexed sku); // <LogSold event: sku arg>

    event LogShipped(uint256 indexed sku); // <LogShipped event: sku arg>

    event LogReceived(uint256 indexed sku); // <LogReceived event: sku arg>

    /*
  /* 
    /*
     * Modifiers
     */

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }

    modifier checkValue(uint256 _sku) {
        //refund them after pay for item (why it is before, _ checks for logic before func)
        _;
        uint256 _price = items[_sku].price;
        uint256 amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }

    modifier forSale(uint256 _sku) {
        require(items[_sku].state == State.ForSale);
        _;
    }
    modifier sold(uint256 _sku) {
        require(items[_sku].state == State.Sold);
        _;
    }

    modifier shipped(uint256 _sku) {
        require(items[_sku].state == State.Shipped);
        _;
    }

    modifier received(uint256 _sku) {
        require(items[_sku].state == State.Received);
        _;
    }

    constructor() public {
        owner = msg.sender;
        skuCount = 0;

    }

    function addItem(string memory _name, uint _price)
        public
        returns (bool)
    {

        items[skuCount] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: State.ForSale,
            seller: msg.sender,
            buyer: address(0)
        });

        skuCount = skuCount + 1;
        emit LogForSale(skuCount);
        return true;
    }

    function buyItem(uint256 sku)
        public
        payable
        forSale(sku)
        paidEnough(items[sku].price)
        checkValue(sku)
    {
        items[sku].buyer = msg.sender;
        items[sku].seller.transfer(items[sku].price);
        items[sku].state = State.Sold;
        emit LogSold(sku);
    }

    function shipItem(uint256 sku) public sold(sku) {

    require(msg.sender == items[sku].seller);
     items[sku].state = State.Shipped;
     emit LogShipped(sku);
    }

    function receiveItem(uint sku) public shipped(sku) {
      require(msg.sender == items[sku].buyer);
            items[sku].state = State.Received;
            emit LogReceived(sku);

    }

      function fetchItem(uint _sku) public view 
      returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
     { 
      name = items[_sku].name; 
       sku = items[_sku].sku; 
       price = items[_sku].price; 
       state = uint(items[_sku].state); 
       seller = items[_sku].seller; 
       buyer = items[_sku].buyer; 
      return (name, sku, price, state, seller, buyer); 
     } 
}
