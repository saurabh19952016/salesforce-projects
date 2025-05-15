({
    init: function (cmp, event, helper) {
        var objList=cmp.get("v.ObjectList");
        if(cmp.get("v.jsonPicklistString")!=''){
            objList=JSON.parse(cmp.get("v.jsonPicklistString"));
            cmp.set("v.ObjectList",objList);
            helper.createPicklistColumns(cmp);
        }
        else{
            var undefinedRows=0;
            for(var i in objList){
                if(objList[i].fieldNameTarget==undefined){
                    undefinedRows+=1;
                }
            }
            helper.createColumns(cmp,undefinedRows);
        }
    }
})