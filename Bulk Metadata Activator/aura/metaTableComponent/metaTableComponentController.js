({
    init: function (component, event, helper) {
        var cols=[];
        cols.push({label: 'Id', fieldName: 'metid', type: 'text'});
        var meta=component.get('v.rec');
        if(meta == 'Flow' || meta == 'ApexTrigger' || meta == 'WorkflowRule')
        {   if(meta == 'Flow')     
            cols.push({label: 'processType', fieldName: 'processType', type: 'text'});
         
         cols.push({label: 'Trigger Type', fieldName: 'triggerType', type: 'text'});
        }
        cols.push({label: 'Component Name', fieldName: 'componentname', type: 'text'});
        cols.push({label: 'Status/ Active', fieldName: 'status',type: 'text'}); 
        var keys = [];
        component.set('v.columns',cols);
        var metamap=component.get("v.records");
        for(var key in metamap){
            keys.push(metamap[key]);
        }
        component.set("v.rows", keys);
    },
    
    
    downloadCsv : function(component, event, helper){
        var stockData = component.get("v.rows");
        
        // call the helper function which "return" the CSV data as a String
        var csv = helper.convertArrayOfObjectsToCSV(component, helper,stockData);
        if (csv == null){return;}
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = component.get("v.rec") + '.csv';  // CSV file Name* you can change it.[only name not .csv]
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); 
    }
})