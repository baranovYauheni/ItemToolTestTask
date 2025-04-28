public with sharing class UnsplashAPI {
    private static final String ACCESS_KEY = 'ZIjEQY4U00W2FYfqg-NxHQEVNQ57KMW7aruQw3V5woQ';
    private static final String UNSPLASH_API_URL = 'https://api.unsplash.com/search/photos';

    @AuraEnabled
    public static void updateItemImage(Id itemId, String itemName) {
        if (itemId == null || String.isBlank(itemName)) {
            return;
        }

        try {
            String url = UNSPLASH_API_URL + '?query=' + EncodingUtil.urlEncode(itemName, 'UTF-8') + '&client_id=' + ACCESS_KEY;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                if (jsonResponse.containsKey('results')) {
                    Object resultsObj = jsonResponse.get('results');

                    if (resultsObj instanceof List<Object>) {
                        List<Object> results = (List<Object>) resultsObj;

                        if (!results.isEmpty()) {
                            Object firstResultObj = results[0];

                            if (firstResultObj instanceof Map<String, Object>) {
                                Map<String, Object> firstResult = (Map<String, Object>) firstResultObj;
                                Object urlsObj = firstResult.get('urls');

                                if (urlsObj instanceof Map<String, Object>) {
                                    Map<String, Object> urls = (Map<String, Object>) urlsObj;
                                    String imageUrl = (String) urls.get('regular');

                                    if (String.isNotBlank(imageUrl)) {
                                        Item__c itemToUpdate = [SELECT Id, Image__c FROM Item__c WHERE Id = :itemId LIMIT 1];
                                        itemToUpdate.Image__c = imageUrl;
                                        update itemToUpdate;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error during API call: ' + e.getMessage());
        }
    }
}