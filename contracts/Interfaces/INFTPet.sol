// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface INFTPet {
    function feed(uint256 tokenId) external;

    function clean(uint256 tokenId) external;

    function play(uint256 tokenId) external;

    function sleep(uint256 tokenId) external;

    function getStatus(uint256 tokenId) external view returns (string memory);

    function getAlive(uint256 tokenId) external view returns (bool);

    function getHunger(uint256 tokenId) external view returns (uint256);

    function getUncleanliness(uint256 tokenId) external view returns (uint256);

    function getBoredom(uint256 tokenId) external view returns (uint256);

    function getSleepiness(uint256 tokenId) external view returns (uint256);

    function getStats(uint256 tokenId) external view returns (uint256[5] memory);
}
