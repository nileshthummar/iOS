# iOS Homework
 

### Deployment Target :
    - 10.0

## Please find my note >> for all
Features

● Please consume this ​JSON feed​.
○ Note: You should do this by performing any necessary network calls in the app.
Do not store this file locally in the app.
>>Done >> PersonAPI.swift for this particular API call 
● Display the feed in a master/detail type app
○ Scrollable view of all events, when tapped leads to a detail view.
○ See ​Wireframes​ for design requirements.
>>Done >>HomeViewController.swift
● Each Event may or may not have an image associated with it.
>>Done, used placeholder image if not available 
● Each Event may or may not have schedule information associated with it.
>>Done
● All schedule times are in GMT, and should be represented in the user’s timezone.
>>Done "static func format(date: String) -> String {" method in Utils.swift class for format date 
● While viewing an event, a user can share via SMS and Email.
○ Note: Sharing via social outlets is no longer required for this test.
>>Not required as per instruction
● Should support both iPhone and iPad
>>Done
● Support the following orientations:
○ Portrait on iPhones (minimum) - This includes Upside-Down Portrait.
○ All orientations on iPads
>>Done
● Should work on the current iOS ​major​ version and the one prior.
>>Done, Deployement target 10.0
● App should function with or without network connection after the first time the data is
loaded.
>>Done using "request.cachePolicy" it will load JSON feed but not all images. if needed for all images we can custom Image cache using NSURLCache. something like https://dinethmendis.com/blog/swift-image-cache-compatible-with-ios7 
● App Icon and Placeholder Image assets can be found ​here
>>Done
