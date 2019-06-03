.pragma library
.import QtQuick.LocalStorage 2.0 as SQL


var signcenter;

function getDatabase() {
    return SQL.LocalStorage.openDatabaseSync("v2ray_configs", "1.0", "configs", 1024*1024*7);
}


function initialize() {
    var db = getDatabase();
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS Configs(remark TEXT primary key, vtype TEXT, config TEXT);');

        });
}

function addconfig(remark, vtype, config ){
    var db = getDatabase();
    try{
        db.transaction(function(tx) {
            var rs = tx.executeSql('insert or replace into Configs(remark, vtype, config) values(?,?,?);', 
                [remark, vtype, config]);
            if (rs.rowsAffected > 0) {
                signcenter.addSuccess();
            }
        })
    }
    catch(e){
        console.log("error...reget")
        signcenter.error();
    }
}



function delconfig(remark){
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('delete from  Configs where remark =?;',[remark]);
        if (rs.rowsAffected > 0) {
            signcenter.deleteSuccess();
        } else {
            signcenter.error();
        }
    }
    );

}

function queryall(model){
    var db = getDatabase();
    var sql = 'SELECT * FROM Configs order by remark desc;';
    model.clear();
    try{
        db.transaction(function(tx) {
            var rs = tx.executeSql(sql);
            if (rs.rows.length > 0) {
                for(var i = 0; i < rs.rows.length; i++){
                    model.append({
                                  "remark": rs.rows.item(i).remark,
                                  "vtype": rs.rows.item(i).vtype,
                                  "config": rs.rows.item(i).config
                                 })
                }
            }
        })
    }
    catch(e){
        console.log("error...reget")
        signcenter.error();
    }
}
