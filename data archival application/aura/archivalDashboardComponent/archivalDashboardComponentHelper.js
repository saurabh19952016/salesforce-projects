({
    inithelper : function(component,event,helper) {
        var action=component.get("c.getReportingData");
        var label=[];
        
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                component.set("v.data",response.getReturnValue());
                var dataObj=response.getReturnValue();
                console.log(response.getReturnValue());
                for(var key in dataObj){
                    label.push(dataObj[key]);
                }
                component.set("v.xAxisCategories",label);
                helper.piechart(component,event,helper);
                helper.linechart(component,event,helper);                
            }
            else{
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    piechart : function(component,event,helper) {
        var dataObj = component.get("v.data");
        /// var dataObj = JSON.parse(jsonData);
        new Highcharts.Chart({
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: true,
                renderTo: component.find("chart").getElement(),
                type: 'pie'
            },
            title: {
                text: 'Big object partition per object (%)'
            },
            subtitle: {
                text: 'sObject storage'
            },
            xAxis: {
                categories:  component.set("v.xAxisCategories"),
                crosshair: true
            },
            yAxis: {
                min: 0,
                title:
                {
                    text: 'yaxis'
                }
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: true,
                        format: '<b>{point.name}</b>: {point.percentage:.1f}% ',
                    },
                    showInLegend: true
                    
                }
            },
            series: [{
                name:'Storage',
                colorByPoint: true,
                
                data:dataObj
            }]
            
        });
        
    },
    
    linechart : function(component,event,helper) {
        var dataObj = component.get("v.data");        
        new Highcharts.Chart({
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: true,
                renderTo: component.find("linechart").getElement(),
                type: 'column'
            },
            title: {
                text: 'Record count per object'
            },
            subtitle: {
                text: 'number of records per sobject'
            },
            xAxis: {
                categories: component.get("v.xAxisCategories"),
                crosshair: true
            },
            yAxis: {
                min: 0,
                title: {
                    text: component.get("v.yAxisParameter")
                },
                labels: {
                    overflow: 'justify'
                }
            },
            tooltip: {
                enabled:false
            },
            plotOptions: {
                series: {
                    dataLabels: {
                        enabled:true,
                        format:'{point.name}:{point.y}',
                        style: {
                            color: 'black'
                        },
                        showInLegend: true,
                        useHTML:true
                    },
                    colorByPoint: true,
                    showInLegend: false,
                    useHTML:true
                    
                },
            },
            series: [{
                showInLegend: false,
                name:'',
                data:dataObj,
                type: 'column'           
            }]
            
        });
        
    },
})