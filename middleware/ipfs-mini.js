const IPFS = require('ipfs-mini');
const bs58 = require('bs58');
const ipfs = new IPFS({host: 'ipfs.infura.io', port: 5001, protocol: 'https'});

function fromIPFSToHex(ipfs) {
    const bytes = bs58.decode(ipfs);
    const multiHashId = 2;
    console
    return bytes.slice(multiHashId, bytes.length).toString("hex");
}

function fromHexToIPFS(str){
    const remove0x = str.slice(2, str.length);
    const bytes = Buffer.from(`1220${remove0x}`, "hex");
    const hash = bs58.encode(bytes);
    return hash;
}

ipfs.addJSON( {name: "Zinedin", description:"Chauve et fier de l'être", image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTF_maaR7ArX1JrNnYoLX6OSwLIt1SdmlYVVVfPIirfejRdIpfer"} , function(err, hash) {
    if(err) {
        return console.log(err);
    }
    return console.log(hash);
});

var hex = fromIPFSToHex("QmeKSrQu9RiaHa9UGVAmKwgz8DxKPe6hhyJiSV1ekcXBP9");
console.log(hex);