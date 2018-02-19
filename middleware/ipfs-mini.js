const IPFS = require('ipfs-mini');
const bs58 = require('bs58');
const ipfs = new IPFS({host: 'ipfs.infura.io', port: 5001, protocol: 'https'});

function fromIPFSToHex(ipfs) {
    const bytes = bs58.decode(ipfs);
    console.log('bytes 1 w/o slice', bytes.toString('hex'));
    const multiHashId = 2;
    console.log('bytes 1 w/ slice',bytes.slice(multiHashId, bytes.length));
    return bytes.slice(multiHashId, bytes.length).toString("hex");
}

function fromHexToIPFS(str){
    const remove0x = str.slice(2, str.length);
    console.log('remove0x',remove0x);
    const bytes = Buffer.from('1220'+remove0x, "hex");
    const hash = bs58.encode(bytes);
    return hash;
}


/*ipfs.addJSON( {name: "Zinedin", description:"Chauve et fier de l'être", image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTF_maaR7ArX1JrNnYoLX6OSwLIt1SdmlYVVVfPIirfejRdIpfer"} , function(err, hash) {
    if(err) {
        return console.log(err);
    }
    return hash;
});*/


var hex = fromIPFSToHex("QmWmyoMoctfbAaiEs2G46gpeUmhqFRDW6KWo64y5r581Vz");
console.log('hex', hex);
var hash = fromHexToIPFS('0x'+hex);
console.log('hash',hash);


