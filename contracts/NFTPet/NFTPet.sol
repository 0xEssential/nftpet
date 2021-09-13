// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract NFTPet is ERC721 {
    event CaretakerLoved(address indexed caretaker, uint256 indexed amount);

    mapping(uint256 => uint256) internal _lastFeedBlock;
    mapping(uint256 => uint256) internal _lastCleanBlock;
    mapping(uint256 => uint256) internal _lastPlayBlock;
    mapping(uint256 => uint256) internal _lastSleepBlock;

    mapping(uint256 => uint8) internal _hunger;
    mapping(uint256 => uint8) internal _uncleanliness;
    mapping(uint256 => uint8) internal _boredom;
    mapping(uint256 => uint8) internal _sleepiness;

    mapping(address => uint256) public love;
    bytes4 private constant _INTERFACE_ID_NFTPET = 0xc155531e;

    function _adopt(uint256 tokenId) internal {
        _lastFeedBlock[tokenId] = block.number;
        _lastCleanBlock[tokenId] = block.number;
        _lastPlayBlock[tokenId] = block.number;
        _lastSleepBlock[tokenId] = block.number;

        _hunger[tokenId] = 0;
        _uncleanliness[tokenId] = 0;
        _boredom[tokenId] = 0;
        _sleepiness[tokenId] = 0;
    }

    function addLove(address caretaker, uint256 amount) internal {
        love[caretaker] += amount;
        emit CaretakerLoved(caretaker, amount);
    }

    function feed(uint256 tokenId) public {
        require(super._exists(tokenId), "pet does not exist");
        require(super.ownerOf(tokenId) == super._msgSender(), "not your pet");
        require(getHunger(tokenId) > 0, "i dont need to eat");
        require(getAlive(tokenId), "no longer with us");
        require(getBoredom(tokenId) < 80, "im too tired to eat");
        require(getUncleanliness(tokenId) < 80, "im feeling too gross to eat");
        require(getSleepiness(tokenId) < 80, "im too sleepy to eat");

        _lastFeedBlock[tokenId] = block.number;

        _hunger[tokenId] = 0;
        _boredom[tokenId] += 10;
        _uncleanliness[tokenId] += 3;

        addLove(super._msgSender(), 1);
    }

    function clean(uint256 tokenId) public {
        require(super._exists(tokenId), "pet does not exist");
        require(super.ownerOf(tokenId) == super._msgSender(), "not your pet");
        require(getAlive(tokenId), "no longer with us");
        require(getUncleanliness(tokenId) > 0, "i dont need a bath");

        _lastCleanBlock[tokenId] = block.number;
        _uncleanliness[tokenId] = 0;

        addLove(super._msgSender(), 1);
    }

    function play(uint256 tokenId) public {
        require(super._exists(tokenId), "pet does not exist");
        require(super.ownerOf(tokenId) == super._msgSender(), "not your pet");
        require(getAlive(tokenId), "no longer with us");
        require(getHunger(tokenId) < 80, "im too hungry to play");
        require(getSleepiness(tokenId) < 80, "im too sleepy to play");
        require(getUncleanliness(tokenId) < 80, "im feeling too gross to play");
        require(getBoredom(tokenId) > 0, "i dont wanna play");

        _lastPlayBlock[tokenId] = block.number;

        _boredom[tokenId] = 0;
        _hunger[tokenId] += 10;
        _sleepiness[tokenId] += 10;
        _uncleanliness[tokenId] += 5;

        addLove(super._msgSender(), 1);
    }

    function sleep(uint256 tokenId) public {
        require(super._exists(tokenId), "pet does not exist");
        require(super.ownerOf(tokenId) == super._msgSender(), "not your pet");
        require(getAlive(tokenId), "no longer with us");
        require(getUncleanliness(tokenId) < 80, "im feeling too gross to sleep");
        require(getSleepiness(tokenId) > 0, "im not feeling sleepy");

        _lastSleepBlock[tokenId] = block.number;

        _sleepiness[tokenId] = 0;
        _uncleanliness[tokenId] += 5;

        addLove(super._msgSender(), 1);
    }

    function getStatus(uint256 tokenId) public view returns (string memory) {
        require(super._exists(tokenId), "pet does not exist");

        uint256 mostNeeded = 0;

        string[4] memory goodStatus = ["gm", "im feeling great", "all good", "i love u"];

        string memory status = goodStatus[block.number % 4];

        uint256 hunger = getHunger(tokenId);
        uint256 uncleanliness = getUncleanliness(tokenId);
        uint256 boredom = getBoredom(tokenId);
        uint256 sleepiness = getSleepiness(tokenId);

        if (getAlive(tokenId) == false) {
            return "no longer with us";
        }

        if (hunger > 50 && hunger > mostNeeded) {
            mostNeeded = hunger;
            status = "im hungry";
        }

        if (uncleanliness > 50 && uncleanliness > mostNeeded) {
            mostNeeded = uncleanliness;
            status = "i need a bath";
        }

        if (boredom > 50 && boredom > mostNeeded) {
            mostNeeded = boredom;
            status = "im bored";
        }

        if (sleepiness > 50 && sleepiness > mostNeeded) {
            mostNeeded = sleepiness;
            status = "im sleepy";
        }

        return status;
    }

    function getAlive(uint256 tokenId) public view returns (bool) {
        require(super._exists(tokenId), "pet does not exist");

        return
            getHunger(tokenId) < 101 &&
            getUncleanliness(tokenId) < 101 &&
            getBoredom(tokenId) < 101 &&
            getSleepiness(tokenId) < 101;
    }

    function getHunger(uint256 tokenId) public view returns (uint256) {
        require(super._exists(tokenId), "pet does not exist");

        return _hunger[tokenId] + ((block.number - _lastFeedBlock[tokenId]) / 400);
    }

    function getUncleanliness(uint256 tokenId) public view returns (uint256) {
        require(super._exists(tokenId), "pet does not exist");

        return _uncleanliness[tokenId] + ((block.number - _lastCleanBlock[tokenId]) / 400);
    }

    function getBoredom(uint256 tokenId) public view returns (uint256) {
        require(super._exists(tokenId), "pet does not exist");

        return _boredom[tokenId] + ((block.number - _lastPlayBlock[tokenId]) / 400);
    }

    function getSleepiness(uint256 tokenId) public view returns (uint256) {
        require(super._exists(tokenId), "pet does not exist");

        return _sleepiness[tokenId] + ((block.number - _lastSleepBlock[tokenId]) / 400);
    }

    function getStats(uint256 tokenId) public view returns (uint256[5] memory) {
        return [
            getAlive(tokenId) ? 1 : 0,
            getHunger(tokenId),
            getUncleanliness(tokenId),
            getBoredom(tokenId),
            getSleepiness(tokenId)
        ];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        if (interfaceId == _INTERFACE_ID_NFTPET) return true;
        return super.supportsInterface(interfaceId);
    }
}
