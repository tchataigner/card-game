var CardCore = artifacts.require("CardCore");


import EVMThrow from './helpers/EVMThrow'
import revert from './helpers/revert'

import {advanceBlock} from './helpers/advanceToBlock'

const should = require('chai')
    .use(require('chai-as-promised'))
    .should();


contract('CardCore', function(accounts) {
    describe('Construct', function() {
        let cardCoreInstance;
        before(async function() {
            cardCoreInstance = await CardCore.new({from: accounts[0]});
        });
        it('should set contract as paused', async function() {
            let paused = await cardCoreInstance.paused.call();
            assert.equal(paused, true);
        });
        it('should set ceo & coo address to account[0]', async function() {
            let ceoAddress = await cardCoreInstance.ceoAddress.call();
            let cooAddress = await cardCoreInstance.cooAddress.call();
            assert.equal(ceoAddress, cooAddress);
        });
        it('should create the supreme card, one to rule them all', async function() {
            let ownershipTokenCount = await cardCoreInstance.balanceOf(0x0);
            assert.equal(ownershipTokenCount, 1);
        });

        /*it('should not work', async () => {
            await myfirstcontractInstance.sendEther.sendTransaction(1000000000000000000000000000000000, accounts[1]).should.be.rejectedWith(revert);
        });*/
    });
});
