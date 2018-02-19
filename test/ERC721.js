var CardCore = artifacts.require("CardCore");
const Web3 = require('web3');
var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

import EVMThrow from './helpers/EVMThrow'
import revert from './helpers/revert'

import {advanceBlock} from './helpers/advanceToBlock'

const should = require('chai')
    .use(require('chai-as-promised'))
    .should();

const utils = require("./helpers/assertEvent.js");

const ipfs = require("./helpers/ipfs.js");


contract('CardCore', function(accounts) {
    describe('ERC721 Features', function() {
        let cardCoreInstance;
        before(async function() {
            cardCoreInstance = await CardCore.new({from: accounts[0]});
            await cardCoreInstance.unpause.sendTransaction({from: accounts[0]});
        });
        //Name Attribute Test
        it('should return the name ( CryptoCards )', async function() {
            let name = await cardCoreInstance.name.call();
            assert.equal(name, "CryptoCards");
        });
        //Symbol Attribute Test
        it('should return the symbol ( CC )', async function() {
            let name = await cardCoreInstance.symbol.call();
            assert.equal(name, "CC");
        });
        //Total Supply func Test
        it('should return totalSupply of cards ( 1 )', async function() {
            let _from = accounts[1];
            let bytes32 = ipfs.fromIPFSToBuffer('QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz');

            await cardCoreInstance.cardGeneration.sendTransaction(_from, bytes32, {from: _from});
            let totalSupply = await cardCoreInstance.totalSupply();

            assert.equal(totalSupply.toNumber(), 1);
        });
        //Balance of func Test
        it('should return balance of card for accounts[1] ( 1 )', async function() {
            let _from = accounts[1];

            let totalSupply = await cardCoreInstance.balanceOf(_from);
            assert.equal(totalSupply.toNumber(), 1);
        });
        /**
         * Owner Of func Test
         */
        it('should not return owner of supreme card', async function() {
            let _cardID = 0;

            await cardCoreInstance.ownerOf(_cardID).should.be.rejectedWith(revert);
        });
        it('should return owner of given card (address _from)', async function() {
            let _from = accounts[1];
            let _cardID = await cardCoreInstance.totalSupply.call();

            let address = await cardCoreInstance.ownerOf(_cardID);
            assert.equal(address, accounts[1]);
        });
        /**
         * Approve Func Test
         */
        it('should not work if msg sender != token owner', async function() {
            let _approved = accounts[2];
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.approve.sendTransaction(_approved, _cardID, {from: _approved}).should.be.rejectedWith(revert);
        });
        it('should add card to cardIndexToApproved', async function() {
            let _approved = accounts[2];
            let _approver = accounts[1];
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.approve.sendTransaction(_approved, _cardID, {from: _approver});
            let cardIndexToApproved = await cardCoreInstance.cardIndexToApproved.call(_cardID);
            assert.equal(cardIndexToApproved, _approved);
        });
        it('should fire Approval event', async function() {
            let _approved = accounts[2];
            let _approver = accounts[1];
            let _bytes32 = ipfs.fromIPFSToBuffer('QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz');

            await cardCoreInstance.cardGeneration.sendTransaction(_approver, _bytes32, {from: _approver});
            let _cardID = await cardCoreInstance.totalSupply.call();

            return cardCoreInstance
                .approve(_approved, _cardID.toNumber(), {from: _approver})
                .then(async function(){
                utils.assertEvent(cardCoreInstance, { event: "Approval", logIndex: 0, args: { owner: _approver, approved: _approved, tokenId: _cardID }})
            });
        });
        /**
         * Transfer Func Test
         */
        it('should not work if address 0', async function() {
            let _from = accounts[1];
            let _to = 0x0;
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.transfer.sendTransaction(_to, _cardID, {from: _from}).should.be.rejectedWith(revert);
        });
        it('should not work if address is of contract', async function() {
            let _from = accounts[1];
            let _to = cardCoreInstance.address;
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.transfer.sendTransaction(_to, _cardID, {from: _from}).should.be.rejectedWith(revert);
        });
        it('should not work if msg sender do not own card', async function() {
            let _from = accounts[2];
            let _to = accounts[3];
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.transfer.sendTransaction(_to, _cardID, {from: _from}).should.be.rejectedWith(revert);
        });
        it('should increment by 1 the number of card owned by the receiver', async function() {
            let _to = accounts[3];
            let _from = accounts[1];
            let _cardID = await cardCoreInstance.totalSupply.call();

            let before = await cardCoreInstance.balanceOf(_to);
            await cardCoreInstance.transfer.sendTransaction(_to, _cardID.toNumber(), {from: _from});
            let after = await cardCoreInstance.balanceOf(_to);

            assert.equal(before.toNumber() + 1, after.toNumber());
        });
        it('should removal approval from a transfered card', async function() {
            let _cardID = await cardCoreInstance.totalSupply.call();

            let cardIndexToApproved = await cardCoreInstance.cardIndexToApproved.call(_cardID);
            assert.equal(cardIndexToApproved, 0x0);
        });
        it('should decrease by 1 the number of card owned by the sender', async function() {
            let _to = accounts[1];
            let _from = accounts[3];
            let _cardID = await cardCoreInstance.totalSupply.call();

            let before = await cardCoreInstance.balanceOf(_from);
            await cardCoreInstance.transfer.sendTransaction(_to, _cardID.toNumber(), {from: _from});
            let after = await cardCoreInstance.balanceOf(_from);

            assert.equal(before.toNumber() - 1, after.toNumber());
        });
        it('should increment transfer ownership', async function() {
            let _to = accounts[3];
            let _from = accounts[1];
            let _bytes32 = ipfs.fromIPFSToBuffer('QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz');

            await cardCoreInstance.cardGeneration.sendTransaction(_from, _bytes32, {from: _from});
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.transfer.sendTransaction(_to, _cardID.toNumber(), {from: _from});
            let address = await cardCoreInstance.ownerOf(_cardID.toNumber());

            assert.equal(address, _to);
        });
        it('should fire Transfer event', async function() {
            let _to = accounts[1];
            let _from = accounts[3];
            let _cardID = await cardCoreInstance.totalSupply.call();

            return cardCoreInstance
                .transfer(_to, _cardID, {from: _from})
                .then(async function(){
                utils.assertEvent(cardCoreInstance, { event: "Transfer", logIndex: 0, args: { from: _from, to: _to, tokenId: _cardID }})
            });
        });
        /**
         * Transfer From func Test
         */
        it('should not work if address 0', async function() {
            let _from = accounts[1];
            let _to = 0x0;
            let _sender = accounts[3]
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.transferFrom.sendTransaction(_from, _to, _cardID, {from: _sender}).should.be.rejectedWith(revert);
        });
        it('should not work if address is of contract', async function() {
            let _from = accounts[1];
            let _to = cardCoreInstance.address;
            let _sender = accounts[3]
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.transferFrom.sendTransaction(_from, _to, _cardID, {from: _sender}).should.be.rejectedWith(revert);
        });
        it('should not work if msg sender is not approved', async function() {
            let _from = accounts[1];
            let _to = accounts[3];
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.transferFrom.sendTransaction(_from, _to, _cardID, {from: _to}).should.be.rejectedWith(revert);
        });
        it('should not work if from address is not owner', async function() {
            let _from = accounts[1];
            let _to = accounts[3];
            let _fake = accounts[8];
            let _cardID = await cardCoreInstance.totalSupply.call();

            await cardCoreInstance.approve.sendTransaction(_to, _cardID, {from: _from});

            await cardCoreInstance.transferFrom.sendTransaction(_fake, _to, _cardID, {from: _to}).should.be.rejectedWith(revert);
        });
        /**
         * tokens of Owner func Test
         */
        it('should return empty array if no token', async function() {
            let _from = accounts[8];

            let tokens = await cardCoreInstance.tokensOfOwner.call(_from, {from: _from});
            assert.equal(tokens.length, 0);
        });
        it('should return array of token IDs', async function() {
            let _from = accounts[1];

            let totalSupply = await cardCoreInstance.totalSupply.call();
            let nbrToken = 0;
            for(let i = 1; i<=totalSupply.toNumber(); i++){
                let address = await cardCoreInstance.ownerOf(i);
                if(address == _from){
                    nbrToken++;
                }
            }

            let tokens = await cardCoreInstance.tokensOfOwner.call(_from, {from: _from});
            assert.equal(tokens.length, nbrToken);
        });
    });
});