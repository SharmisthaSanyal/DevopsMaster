@isTest
global class LeadsPostHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    
     global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse patchResponse = new HttpResponse();
        patchResponse.setHeader('Content-Type', 'application/json');
        patchResponse.setHeader('x-csrf', 'tqQuilerZrK1N31UzeotIg==');
        patchResponse.setHeader('set-cookie', 'SAP_SESSIONID_LXW_011=44AVcWRjCzGHsog7RgCGdUpi80BiDRHqnFUAFj6SKrI%3d');
        patchResponse.setStatusCode(204);
        return patchResponse; 
    }
}