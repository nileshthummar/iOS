//
//  LFCache.m
//  Watchback
//
//  Created by Nilesh on 11/13/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import "LFCache.h"
#import "JLManager.h"
static LFCache * manager;
@interface DLinkedNode:NSObject
{
    @public NSString * key;
    @public NSString *value;
    @public DLinkedNode *pre;
    @public DLinkedNode *post;
}
@end
@implementation DLinkedNode
-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
   
    if(self) {
        self->key = [decoder decodeObjectForKey:@"keyKey"];
        self->value = [decoder decodeObjectForKey:@"valueKey"];
        self->pre = [decoder decodeObjectForKey:@"preKey"];
        self->post = [decoder decodeObjectForKey:@"postKey"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self->key forKey:@"keyKey"];
    [encoder encodeObject:self->value forKey:@"valueKey"];
    [encoder encodeObject:self->pre forKey:@"preKey"];
    [encoder encodeObject:self->post forKey:@"postKey"];
}

@end
/*class DLinkedNode {
    NSString * key;
    NSString *value;
    struct DLinkedNode *pre;
    struct DLinkedNode *post;
}dLinkedNode;*/
@interface LFCache()
{
    int count;
    int capacity;
    DLinkedNode *head;
    DLinkedNode *tail;
    NSMutableDictionary *cache;
}
@end

@implementation LFCache
+(LFCache *)sharedManager{
    
    if(manager==nil){
         if (kDebugLog)NSLog(@"LFCache sharedManager");
        manager = [[LFCache alloc] init];
        NSDictionary *dict = [[JLManager sharedManager] getObjectuserDefault:kLongformVideoPositionCacheKey];
        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
            manager->count = [[dict objectForKey:@"count"] intValue];
            manager->capacity = [[dict objectForKey:@"capacity"] intValue];
            manager->head = [dict objectForKey:@"head"];
            manager->tail = [dict objectForKey:@"tail"];
            manager->cache = [dict objectForKey:@"cache"];
            
            if (kDebugLog)NSLog(@"LFCache sharedManager Load %@",dict);
        }
        else{
            manager->cache = [NSMutableDictionary new];
            manager->count = 0;
            
            
            manager->head = [DLinkedNode new];
            manager->head->pre = nil;
            
            manager->tail = [DLinkedNode new];
            manager->tail->post = nil;
            
            manager->head->post = manager->tail;
            manager->tail->pre = manager->head;
            
            if (kDebugLog)NSLog(@"LFCache sharedManager new");
        }
        
    }
    return manager;
}

-(void )setCapacity:(int)capacity {
     if (kDebugLog)NSLog(@"LFCache setCapacity %d",capacity);
    self->capacity = capacity;
}

-(NSString *) get:(NSString *) key {
     if (kDebugLog)NSLog(@"LFCache get Key -> %@",key);
    DLinkedNode *node = [cache objectForKey:key];
    if(node == nil){
        return nil; // should raise exception here.
    }
    
    // move the accessed node to the head;
    [self moveToHead:node];
    if (kDebugLog)NSLog(@"LFCache get value -> %@",node->value);
    return node->value;
}


-(void) set:(NSString *)key value:(NSString *)value {
     if (kDebugLog)NSLog(@"LFCache set -> %@ , value -> %@",key,value);
    DLinkedNode *node = [cache objectForKey:key];
    
    if(node == nil){
        if (kDebugLog)NSLog(@"LFCache Set New");
        DLinkedNode *newNode = [DLinkedNode new];
        newNode->key = key;
        newNode->value = value;
        
        [cache setObject:newNode forKey:key];
        //this.cache.put(key, newNode);
        [self addNode:newNode];
        
        ++count;
        
        if(count > capacity){
            // pop the tail
            DLinkedNode *tail = [self popTail];
            [self->cache removeObjectForKey:tail->key];
            --count;
        }
    }else{
        if (kDebugLog)NSLog(@"LFCache Set Replace");
        // update the value.
        node->value = value;
        [self moveToHead:node];
    }
    
}
-(void) remove:(NSString *) key{
     if (kDebugLog)NSLog(@"LFCache remove");
    DLinkedNode *node = [cache objectForKey:key];
    if(node != nil){
         if (kDebugLog)NSLog(@"LFCache remove Exist");
        [self removeNode:node];
        [self->cache removeObjectForKey:node->key];
        --count;
    }
}
    
/**
 * Always add the new node right after head;
 */
- (void) addNode :(DLinkedNode *) node{
     if (kDebugLog)NSLog(@"LFCache addNode Key -> %@ , Value -> %@",node->key,node->value);
    node->pre = head;
    node->post = head->post;
    head->post->pre = node;
    head->post = node;
}
/**
* Remove an existing node from the linked list.
*/
-(void) removeNode:(DLinkedNode*) node{
     if (kDebugLog)NSLog(@"LFCache removeNode Key -> %@ , Value -> %@",node->key,node->value);
    if (node != nil) {
        DLinkedNode *pre = node->pre;
        DLinkedNode *post = node->post;
        
        if(pre != nil)pre->post = post;
        if(post != nil)post->pre = pre;
    }
    
}
/**
 * Move certain node in between to the head.
 */
-(void) moveToHead:(DLinkedNode *)node{
    if (kDebugLog)NSLog(@"LFCache moveToHead Key -> %@ , Value -> %@",node->key,node->value);
    [self removeNode:node];
    [self addNode:node];
}

// pop the current tail.
-(DLinkedNode *) popTail{
    
    DLinkedNode *res = tail->pre;
    if (kDebugLog)NSLog(@"LFCache popTail Key -> %@ , Value -> %@",res->key,res->value);
    [self removeNode:res];
    return res;
}
-(void)saveData{
     if (kDebugLog)NSLog(@"LFCache saveData");
    if (count > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
        [dict setObject:[NSString stringWithFormat:@"%d",capacity] forKey:@"capacity"];
        [dict setObject:head forKey:@"head"];
        [dict setObject:tail forKey:@"tail"];
        [dict setObject:cache forKey:@"cache"];
        if (kDebugLog)NSLog(@"LFCache saveData %@",dict);
        [[JLManager sharedManager] setObjectuserDefault:dict forKey:kLongformVideoPositionCacheKey];
    }
    
}
-(void)resetData{
     if (kDebugLog)NSLog(@"LFCache resetData");
    if (count > 0) {
        if(manager->cache){
            [manager->cache removeAllObjects];
        }
        manager->count = 0;
        
        manager->head = [DLinkedNode new];
        manager->head->pre = nil;
        
        manager->tail = [DLinkedNode new];
        manager->tail->post = nil;
        
        manager->head->post = manager->tail;
        manager->tail->pre = manager->head;
    }
    
}
@end
