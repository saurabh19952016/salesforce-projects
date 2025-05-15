({
    init:function(component,event,helper){
        var method=component.get("v.method");
        var action=component.get(method);

        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                component.set("v.InputListToSearch",response.getReturnValue());  
                var selected=component.get("v.selected");
                if(selected!=null && selected!='')
                {
                    console.log('found id');
                    $A.util.toggleClass(component.find("lookup-pill"), 'slds-hide');
                    $A.util.toggleClass(component.find("lookupField"), 'slds-hide');
                }
                
                console.log('selected record' + component.get("v.selected"));     
            }
        });
        $A.enqueueAction(action);
    },
    
    searchHelper : function(component,event,getInputkeyWord) {
        var InputListToSearch=component.get("v.InputListToSearch");
        var SearchKeyWord=component.get("v.SearchKeyWord");
        if(SearchKeyWord!=undefined){

        SearchKeyWord=SearchKeyWord.toLowerCase();
        var listOfRecords=[];
        var count=0;
        for(var i=0;i<InputListToSearch.length;i++ && count<5){
            if(InputListToSearch[i].Name.toLowerCase().includes(SearchKeyWord)){
                listOfRecords.push(InputListToSearch[i]);
                count++;

            }
        }
       component.set("v.listOfSearchRecords",listOfRecords);
    }

    },
})