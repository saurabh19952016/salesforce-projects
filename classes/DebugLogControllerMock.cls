@istest
public class DebugLogControllerMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getMethod()=='GET' && req.getEndpoint().containsIgnoreCase('sobjects/TraceFlag')){
                        res.setHeader('Content-Type', 'application/json');
            res.setBody('{"records":[{"Id":"'+userinfo.getuserId()+'"}]}');
            res.setStatusCode(200);
            
        }
        else if(req.getMethod()=='GET' && req.getEndpoint().containsIgnoreCase('getUser')){
			res.setHeader('Content-Type', 'application/json');
            res.setBody('{"'+Screen_recorder_settings__c.getInstance('API_user_Id').field_value__c+'":"'+userinfo.getuserId()+'"}');
            res.setStatusCode(200);
        }
        else if (req.getMethod()=='GET' && req.getEndpoint().containsIgnoreCase('SUM(LogLength)')){
            res.setHeader('Content-Type', 'text/plain');
            res.setBody('{"records":[{"expr0":300000000000}]}');
            res.setStatusCode(200);               
        }
        else if(req.getMethod()=='GET' && req.getEndpoint().containsIgnoreCase('tooling/query')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"records":[{"Id":"'+userinfo.getuserId()+'"}]}');
            res.setStatusCode(200);           
        }
        else if (req.getMethod()=='POST' && req.getEndpoint().containsIgnoreCase('sobjects/TraceFlag')){
            res.setStatus('Created');
            res.setBody('{"id":"'+userinfo.getuserId()+'"}');
            res.setStatusCode(200);               
        }
        else if (req.getMethod()=='GET' && req.getEndpoint().containsIgnoreCase('sobjects/ApexLog')){
            res.setHeader('Content-Type', 'text/plain');
            res.setBody('test Debug log');
            res.setStatusCode(200);               
        }
                else if (req.getMethod()=='DELETE' && req.getEndpoint().containsIgnoreCase('sobjects/TraceFlag')){
            res.setStatusCode(200);               
        }
        else if (req.getMethod()=='DELETE' && req.getEndpoint().containsIgnoreCase('sobjects/ApexLog')){
            res.setStatusCode(200);               
        }
        else if (req.getMethod()=='POST' && req.getEndpoint()==Screen_recorder_settings__c.getInstance('API_creation_endpoint').field_value__c){
            res.setHeader('Content-Type', 'text/plain');
            res.setBody('{"result":{"'+Screen_recorder_settings__c.getInstance('API_incidentNumber').field_value__c+'":"testId"}}');
            res.setStatusCode(200);               
        }
        else if (req.getMethod()=='GET' && req.getEndpoint()==Screen_recorder_settings__c.getInstance('API_getGroup_endpoint').field_value__c){
            res.setHeader('Content-Type', 'text/plain');
            res.setBody('{"result":[{"'
                        +Screen_recorder_settings__c.getInstance('API_group_Id').field_value__c+'":"testId","'
                        +Screen_recorder_settings__c.getInstance('API_group_name').field_value__c+'":"testName"'
                        +'}]}');
            res.setStatusCode(200);               
        }
        return res;
        
    }
    
}