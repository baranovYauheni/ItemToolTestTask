@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    private String responseBody;
    private Integer statusCode;

    public MockHttpResponseGenerator(String responseBody, Integer statusCode) {
        this.responseBody = responseBody;
        this.statusCode = statusCode;
    }

    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setBody(responseBody);
        response.setStatusCode(statusCode);
        return response;
    }
}