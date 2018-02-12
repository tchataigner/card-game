var Repo = require('ipfs-repo');


const MemoryStore = require('interface-datastore').MemoryDatastore;
const MountStore = require('datastore-core').MountDatastore;
const Key = require('interface-datastore').Key;


/*
,
    {
        storageBackends: {
            root: MountStore,
            keys: Key,
            datastore: MemoryStore
        }
    }
 */
const repo = new Repo(
    '/tmp/ipfs-repo'
    )


/*repo.put('Zinedin Zidane #1', jsonToBuffer({legend: true, hair: 'bald'}), function(res) {
    console.log(res);
})

repo.get('Zinedin Zidane #1', function(res) {
    console.log(res);
})*/
repo.init({ cool: 'config' }, function(call){
    if (call) {
        throw call
    }
    repo.open(function(call){
        if (call) {
            throw call
        }

        repo.put(new Key('/Zinedin #1'), jsonToBuffer({legend: true, hair: 'bald'}), function(call){
            if (call) {
                throw call
            }
            repo.exists(function(call,bool){console.log(bool)});
        })
    });
});




function jsonToBuffer(json){
    let buf = Buffer.from(JSON.stringify(json));
    return buf;
}

function bufferToJSON(buffer){
    let temp = JSON.parse(buf.toString());
    return temp;
}

