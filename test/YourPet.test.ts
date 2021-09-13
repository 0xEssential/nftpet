import {expect} from './chai-setup';
import {ethers, deployments} from 'hardhat';
import {setupUser} from './utils';
import {BigNumber, Contract} from 'ethers';

// follow https://github.com/nomiclabs/hardhat/issues/1112
// re: adding more performant way to mock block number
const timetravelBlocks = async (blocks: number) => {
  const blockNumBefore = await ethers.provider.getBlockNumber();
  const blockBefore = await ethers.provider.getBlock(blockNumBefore);
  const timestampBefore = blockBefore.timestamp;

  const blocksArr = Array.from(
    {length: blocks},
    (_, i) => timestampBefore + i + 1
  );

  for (const i of blocksArr) {
    await ethers.provider.send('evm_increaseTime', [i]);
    await ethers.provider.send('evm_mine', [i]);
  }
};

const setup = deployments.createFixture(async () => {
  const YourPetContract = await ethers.getContractFactory('YourPet');

  const YourPet = await YourPetContract.deploy();

  const [_owner] = await ethers.getSigners();
  const owner = await setupUser(_owner.address, {YourPet});

  const mint = await owner.YourPet.mintItem();

  await mint.wait();

  return {owner, YourPet};
});

describe('YourPet', function () {
  let fixtures: {
    owner: {
      address: string;
    } & {
      YourPet: Contract;
    };
    YourPet: Contract;
  };

  before(async () => {
    fixtures = await setup();
  });

  describe('mint condition', function () {
    it('is alive', async () => {
      const {YourPet} = fixtures;

      const alive = await YourPet.getAlive(1);

      expect(alive).to.eq(true);
    });

    it('has base stats', async () => {
      const {YourPet} = fixtures;

      const stats = await YourPet.getStats(1);

      expect(stats).to.eql([
        BigNumber.from(1),
        BigNumber.from(0),
        BigNumber.from(0),
        BigNumber.from(0),
        BigNumber.from(0),
      ]);
    });

    it('has happy status', async () => {
      const {YourPet} = fixtures;

      const status = await YourPet.getStatus(1);

      const statuses = ['gm', 'im feeling great', 'all good', 'i love u'];

      expect(statuses).to.include(status);
    });
  });

  describe('500 blocks later', function () {
    before(async () => {
      timetravelBlocks(500);
    });

    it('is still alive', async () => {
      const {YourPet} = fixtures;

      const alive = await YourPet.getAlive(1);

      expect(alive).to.eq(true);
    });

    it('has needs', async () => {
      const {YourPet} = fixtures;

      const stats = await YourPet.getStats(1);
      expect(stats).to.eql([
        BigNumber.from(1),
        BigNumber.from(1),
        BigNumber.from(1),
        BigNumber.from(1),
        BigNumber.from(1),
      ]);
    });

    it('has happy status', async () => {
      const {YourPet} = fixtures;

      const status = await YourPet.getStatus(1);

      const statuses = ['gm', 'im feeling great', 'all good', 'i love u'];

      expect(statuses).to.include(status);
    });

    it('can be fed', async () => {
      const {owner, YourPet} = fixtures;

      await owner.YourPet.feed(1);
      const hunger = await YourPet.getHunger(1);

      expect(hunger).to.eq(0);
    });
  });
});
