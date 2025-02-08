// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface DukeCompsciToken {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowancesOf(address account, address spender) external view returns (uint256);
}

contract AMMPool {
    DukeCompsciToken tokenX;
    DukeCompsciToken tokenY;
    event Debug(uint256 value);
    event SwapExecuted(address indexed user, uint256 amountX, uint256 amountY, uint256 reserveX, uint256 reserveY);

    constructor(address _tokenX, address _tokenY) {
        tokenX = DukeCompsciToken(_tokenX);
        tokenY = DukeCompsciToken(_tokenY);
    }

    function swapXY(uint256 amountX) public {
        //uint256 A_asset_param = tokenX.balanceOf(msg.sender) * tokenY.balanceOf(msg.sender);
        uint256 B_asset_param = tokenX.balanceOf(address(this)) * tokenY.balanceOf(address(this));
        uint256 B_assetY_old = tokenY.balanceOf(address(this));

        require(tokenX.allowancesOf(msg.sender, address(this)) >= amountX, "Approval required for tokenX");
        require(tokenX.balanceOf(msg.sender) >= amountX, "Insufficient tokenX balance");
        require(tokenX.transferFrom(msg.sender, address(this), amountX), "TokenX transfer failed");

        uint256 B_asset1_new = tokenX.balanceOf(address(this));
        uint256 B_asset2_new = B_asset_param/B_asset1_new;
        uint256 amountY_trans = B_assetY_old - B_asset2_new;

        //require(amountY_trans > B_assetY_old, "Insufficient tokenY liquidity");
        require(tokenY.transfer(msg.sender, amountY_trans), "TokenY transfer failed");

        emit SwapExecuted(msg.sender, amountX, amountY_trans, B_asset1_new, B_asset2_new);
    }

    function getAllowance() public view returns (uint256, uint256) {
        return (tokenX.allowancesOf(msg.sender, address(this)), tokenY.allowancesOf(msg.sender, address(this)));
    }

    function addLiquidity(uint256 amountX, uint256 amountY) public {
        require(tokenX.transferFrom(msg.sender, address(this), amountX), "TokenX transfer failed");
        require(tokenY.transferFrom(msg.sender, address(this), amountY), "TokenY transfer failed");
    }

    function getUserStatus() public view returns (uint256, uint256) {
        return (tokenX.balanceOf(msg.sender), tokenY.balanceOf(msg.sender));
    }

    function getPoolStatus() public view returns (uint256, uint256) {
        return (tokenX.balanceOf(address(this)), tokenY.balanceOf(address(this)));
    }
}
