@isTest
global class LeadsHttpCalloutMock implements HttpCalloutMock { 
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse Response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        Response.setHeader('x-csrf-token', 'tqQuilerZrK1N31UzeotIg==');
        Response.setHeader('set-cookie', 'SAP_SESSIONID_LXW_011=bls48GC6-f0zs8WUoQggkhQrGx9i0BHqntkAFj6SKrI%3d; path=/; secure; HttpOnly;HttpOnly;Secure;MYSAPSSO2=AjQxMDMBABhLADkAMQBLAEIAQwBGADQANgBYADQAIAACAAYwADEAMQADABBMAFgAVwAgACAAIAAgACAABAAYMgAwADIAMAAwADMAMQAwADEAMwAwADcABQAEAAAACAYAAlgACQACRQD%2fAPowgfcGCSqGSIb3DQEHAqCB6TCB5gIBATELMAkGBSsOAwIaBQAwCwYJKoZIhvcNAQcBMYHGMIHDAgEBMBkwDjEMMAoGA1UEAxMDTFhXAgcgGQchITZVMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMDAzMTAxMzA3MjFaMCMGCSqGSIb3DQEJBDE');
        Response.setStatusCode(200);
        Response.setBody('{"d":{"results":[{"QualificationLevelCode":"Z5"}]}}');
        return Response; 
    }
}