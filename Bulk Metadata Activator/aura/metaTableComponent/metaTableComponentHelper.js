({
    convertArrayOfObjectsToCSV : function(component,helper, objectRecords){
        var csvStringResult, counter, columnDivider, lineDivider;
        var keys=[],labels=[];
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        var obj=component.get("v.object").toUpperCase();
        // store ,[comma] in columnDivider variable for separate CSV values and
        // for start next line use '\n' [new line] in lineDivider variable
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys valirable store fields API Names as a key
        // this labels use in CSV file header
        var columns=component.get("v.columns");
        for(var i=0;i<columns.length;i++){
            //var json = JSON.parse(columns[i]);
            keys.push(columns[i]['fieldName']);
            if(i==0)
                labels.push('Object Name');
            else
                labels.push(columns[i]['label']);
        }
        console.log(keys);
        
        csvStringResult = '';
        csvStringResult += labels.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){
            counter = 0;
            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey];
                console.log(skey);
                console.log(objectRecords[i][skey]);
                // add , [comma] after every String value,. [except first]
                if(counter > 0){
                    csvStringResult += columnDivider;
                }
                if(skey=='metid')
                    csvStringResult += '"'+ obj+'"';
                else
                    csvStringResult += '"'+ objectRecords[i][skey]+'"';
                
                counter++;
                
            }
            
            csvStringResult += lineDivider;
        }
        helper.createDocument(component,helper,csvStringResult);
        return csvStringResult;
    },
    
    createDocument:function(component,helper,csv){
        var action=component.get("c.documentHistory");
        action.setParams({
            "csvFileBody":csv,
            "metadata":component.get("v.rec"),
            "objectName":component.get("v.object")
        });
        console.log("createDoc");
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
               var appEvent = $A.get("e.c:RefreshHistoryEvent");
				appEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})