public with sharing class PostToChatterUtility {

	public FeedItem postToChatter(String chatterFeed, Id parentId){
        FeedItem oChatterFeedItem = new FeedItem();
        
        oChatterFeedItem.Body = chatterFeed;
        oChatterFeedItem.ParentId = parentId;
        
        return oChatterFeedItem;
	}
}