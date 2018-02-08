var Myfirstcontract = artifacts.require("Myfirstcontract");


import EVMThrow from './helpers/EVMThrow'
import revert from './helpers/revert'

import {advanceBlock} from './helpers/advanceToBlock'

const should = require('chai')
    .use(require('chai-as-promised'))
    .should();


contract('Myfirstcontract', function(accounts) {
    describe('General Features', () => {
        let myfirstcontractInstance;
        before(async () => {
            myfirstcontractInstance = await Myfirstcontract.new({ from: accounts[0]});
        });

        it('should set owner to account[0]', async () => {
            let owner = await myfirstcontractInstance.owner.call();
            assert.equal(owner, accounts[0]);
        });
        it('should receive ether', async () => {
            await myfirstcontractInstance.sendTransaction({from: accounts[1], value: 1000000000000000000});
            let balance = await myfirstcontractInstance.etherReceived.call();
            assert.equal(balance, 1000000000000000000);
        });
        it('should send ether', async () => {
            let balanceAccount1Before = web3.eth.getBalance(accounts[1]);
            await myfirstcontractInstance.sendEther.sendTransaction(100000000000000000, accounts[1]);
            let balanceAccount1 = web3.eth.getBalance(accounts[1]);

            assert.isAbove(balanceAccount1, balanceAccount1Before);
        });
        it('should not work', async () => {
            await myfirstcontractInstance.sendEther.sendTransaction(1000000000000000000000000000000000, accounts[1]).should.be.rejectedWith(revert);
        });
    });
});