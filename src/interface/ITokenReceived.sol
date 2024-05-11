pragma solidity ^0.8.0;
interface ITokenReceiver {
    function tokensReceived(
        address from,
        address to,
        uint256 amount,
        bytes memory userData
    ) external;
}
