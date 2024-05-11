// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./library/Address.sol";
import "./interface/ITokenReceived.sol";

contract BaseERC20 is ERC20 {
    using Address for address;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) ERC20(_name, _symbol)  {
        _mint(msg.sender, _totalSupply);
    }

    function _checkOnTokenReceived(address _to, bytes memory _data) private {}

    function transferWithCallBack(
        address _to,
        uint256 _value,
        bytes memory _data
    )public {
        transfer((_to), _value);
        if(_to.isContract()){
            ITokenReceiver(_to).tokensReceived(msg.sender, _to, _value, _data);
        }
    }
}