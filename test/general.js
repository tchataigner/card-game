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
    describe('General Features', function() {
        let cardCoreInstance;
        before(async function() {
            cardCoreInstance = await CardCore.new({from: accounts[0]});
            await cardCoreInstance.unpause.sendTransaction({from: accounts[0]});
        });
        it('should generate a new card for account 1', async function() {
            let bytes32 = ipfs.fromIPFSToBuffer('QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz');
            await cardCoreInstance.cardGeneration.sendTransaction(accounts[1], bytes32, {from: accounts[1]});
            let ownershipTokenCount = await cardCoreInstance.balanceOf(accounts[1]);
            assert.equal(ownershipTokenCount, 1);
        });
        it('should generate incrementing ID for card', async function() {
            let bytes32 = ipfs.fromIPFSToBuffer('QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz');
            let totalSupply = await cardCoreInstance.totalSupply();
            let cardID = await cardCoreInstance.cardGeneration.call(accounts[1], bytes32, {from: accounts[1]});

            assert.equal(cardID, parseFloat(totalSupply) + 1);
        });
        it('should get card info', async function() {
            let bytes32 = ipfs.fromIPFSToBuffer('QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz');
            await cardCoreInstance.cardGeneration.sendTransaction(accounts[1], bytes32,{from: accounts[1]});
            let totalSupply = await cardCoreInstance.totalSupply();
            let card = await cardCoreInstance.getCard.call(parseFloat(totalSupply), {from: accounts[1]});
            let ipfsHash = ipfs.fromHexToIPFS(card[1]);
            assert.equal(ipfsHash, 'QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz');
        });
        it('should fire Creation event', async function() {
            let bytes32 = ipfs.fromIPFSToBuffer('QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz');
            return cardCoreInstance
                .cardGeneration(accounts[1], bytes32, {from: accounts[1]})
                .then(async function(){
                    let totalSupply = await cardCoreInstance.totalSupply();
                    utils.assertEvent(cardCoreInstance, { event: "Creation", logIndex: 0, args: { owner: accounts[1], cardID: totalSupply }})
                });
        });
    });
});