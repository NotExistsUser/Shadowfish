.pragma library

function handler(confText){
    var thisconfig = {};
    if(confText.indexOf("vmess://") == 0 ){
        var c = confText.substring("vmess://".length);
        var conf = Qt.atob(c);
        // {
        //     "v": "2",
        //     "ps": "remark",
        //     "add": "example.com",
        //     "port": "443",
        //     "id": "fc72bsa4-100f-467e-a6f3-4a12bcab1097",
        //     "aid": "64",
        //     "net": "ws",
        //     "type": "none",
        //     "host": "example.com",
        //     "path": "/path/",
        //     "tls": "tls"
        //   }
        var confJson = JSON.parse(conf);
        thisconfig.remark = confJson.ps;
        thisconfig.server = confJson.add;
        thisconfig.port = confJson.port;
        thisconfig.uuid = confJson.id;
        thisconfig.alterid = confJson.aid;
        thisconfig.network = confJson.net;
        thisconfig.type = confJson.type;
        thisconfig.host = confJson.host;
        thisconfig.path = confJson.path;
        thisconfig.tls = confJson.tls;
        thisconfig.insecure = "true";
        thisconfig.vtype = "Vmess";
        thisconfig.security = "auto"; // ??? 
        
    }else if(confText.indexOf("ss://") == 0){
        // ss://YWVzLTI1Ni1jZmI6cGFzc3dkQDEyMy4xMS4xMi4xNDoxMDgxCg==#ss
        var c = confText.substring("ss://".length);
        var remark = c.split("#")[1];
        var conf = Qt.atob(c.split("#")[0]) // aes-256-cfb:password@ip:port
        var configs = conf.split(":");
        thisconfig.remark = remark;
        thisconfig.server = configs[1].split("@")[1]
        thisconfig.port = configs[2];
        thisconfig.vtype = "ShadowSocks";
        thisconfig.uuid = configs[1].split("@")[0]
        thisconfig.security = configs[0];

    }else{
        // not a validate format
        thisconfig = null;
    }

    return thisconfig;
}
