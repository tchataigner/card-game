var CardCore = artifacts.require("CardCore");


import EVMThrow from './helpers/EVMThrow'
import revert from './helpers/revert'

import {advanceBlock} from './helpers/advanceToBlock'

const should = require('chai')
    .use(require('chai-as-promised'))
    .should();


contract('CardCore', function(accounts) {
    describe('General Features', () => {
        let cardCoreInstance;
    before(async () => {
        cardCoreInstance = await CardCore.new({from: accounts[0]});
});

    it('should set owner to account[0]', async () => {
        let ceoAddress = await cardCoreInstance.ceoAddress.call();
    assert.equal(ceoAddress, accounts[0]);
});

    /*it('should not work', async () => {
        await myfirstcontractInstance.sendEther.sendTransaction(1000000000000000000000000000000000, accounts[1]).should.be.rejectedWith(revert);
    });*/
});
});
