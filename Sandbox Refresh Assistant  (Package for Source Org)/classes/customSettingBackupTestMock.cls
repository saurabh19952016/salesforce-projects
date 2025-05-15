@istest
public class customSettingBackupTestMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
       if(req.getMethod()=='POST'){
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"v1","Status":"Success"}');
		res.setStatusCode(200);
        }
        else if(req.getMethod()=='DELETE'){
         res.setHeader('Content-Type', 'application/json');
         res.setBody('{"Status":"Success"}');
         res.setStatusCode(200);           
        }
        else if(req.getMethod()=='GET'){
               res.setHeader('Content-Type', 'application/json');
            res.setBody('{"isSizeExceeded":true}');
         res.setStatusCode(200);    
        }
        return res;
    }
}