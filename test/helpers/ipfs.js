const IPFS = require('ipfs-mini');
const bs58 = require('bs58');

module.exports = {
    fromHexToIPFS: function(str){
        const remove0x = str.slice(2, str.length);
        const bytes = Buffer.from('1220'+remove0x, "hex");
        const hash = bs58.encode(bytes);
        return hash;
    },
    fromIPFSToBuffer: function(ipfs) {
        const bytes = bs58.decode(ipfs);
        const multiHashId = 2;
        return "0x"+bytes.slice(multiHashId, bytes.length).toString("hex");
    }
}