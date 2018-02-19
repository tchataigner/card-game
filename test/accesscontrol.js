var CardCore = artifacts.require("CardCore");


import EVMThrow from './helpers/EVMThrow'
import revert from './helpers/revert'

import {advanceBlock} from './helpers/advanceToBlock'

const should = require('chai')
    .use(require('chai-as-promised'))
    .should();

const utils = require("./helpers/assertEvent.js");

contract('CardCore', function(accounts) {
    describe('Restricted Access Features', function() {
        let cardCoreInstance;
        before(async function() {
            cardCoreInstance = await CardCore.new({from: accounts[0]});
        });
        it('should set cfo address to accounts[0]', async function() {
            await cardCoreInstance.setCFO.sendTransaction(accounts[0], {from: accounts[0]});
            let cfoAddress = await cardCoreInstance.cfoAddress.call();
            assert.equal(cfoAddress, accounts[0]);
        });
        it('should break because contract paused', async function() {
            await cardCoreInstance.pause.sendTransaction({from: accounts[0]}).should.be.rejectedWith(revert);
        });
        it('should unpaused the contract', async function() {
            await cardCoreInstance.unpause.sendTransaction({from: accounts[0]});
            let paused = await cardCoreInstance.paused.call();
            assert.equal(paused, false);
        });
        it('should set not work cause not CLevel', async function() {
            await cardCoreInstance.setSecondsPerBlock.sendTransaction(20, {from: accounts[1]}).should.be.rejectedWith(revert);
        });
        it('should set secondsPerBlock to asked value', async function() {
            let sec = 20;
            await cardCoreInstance.setSecondsPerBlock.sendTransaction(sec, {from: accounts[0]});
            let secondsPerBlock = await cardCoreInstance.secondsPerBlock.call();
            assert.equal(sec, secondsPerBlock);
        });
        it('should set autoGenerationFee to asked value', async function() {
            let fees = 100000;
            await cardCoreInstance.setAutoGenerationFee.sendTransaction(fees, {from: accounts[0]});
            let autoGenerationFee = await cardCoreInstance.autoGenerationFee.call();
            assert.equal(fees, autoGenerationFee);
        });
        it('should break because contract unpaused', async function() {
            await cardCoreInstance.unpause.sendTransaction({from: accounts[0]}).should.be.rejectedWith(revert);
        });
        it('should paused the contract', async function() {
            await cardCoreInstance.pause.sendTransaction({from: accounts[0]});
            let paused = await cardCoreInstance.paused.call();
            assert.equal(paused, true);
        });
        it('should set new contract addresss to accounts[9]', async function() {
            await cardCoreInstance.setNewAddress.sendTransaction(accounts[9], {from: accounts[0]});
            let newContractAddress = await cardCoreInstance.newContractAddress.call();
            assert.equal(newContractAddress, accounts[9]);
        });
        it('should fire ContractUpgrade event', async function() {
            return cardCoreInstance
                .setNewAddress(accounts[8], {from: accounts[0]})
                .then(function(){
                    utils.assertEvent(cardCoreInstance, { event: "ContractUpgrade", logIndex: 0, args: { newContract: accounts[8] }})
                });
        });
        it('should not unpause cause new contract address specified', async function() {
            await cardCoreInstance.unpause.sendTransaction({from: accounts[0]}).should.be.rejectedWith(revert);
        });
    });
});