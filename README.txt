Fork that fixes some issues and add some useful features.


*** Added a tag property to requests ***
Added a new feature. Now requests have a tag field (similar to UIAlertView) called requestTag. Now is possible to process several request responses in the same class at the same time.
Field's name is requestTag instead of tag because there is already a tag property in EC2 classes about EC2 instances.
Has been implemented in all SimpleDB classes and should very easy to implement in all other Amazon services.

Comparative using tags in a real project that has a class called ScoreModel created for uploading high scores, upload scores, create private rankings, list private rankings…
Using dummy classes in ScoreModel class: 118+822=940 lines.
Using tags in ScoreModel: 57+637=694= lines.
Version that uses tag request is smaller, easier to read, write and maintain. 


*** Fixed some warnings about AmazonLogger ***


*** Issue with NSTimer ***
Fixed a critical issue with NSTimer.
https://forums.aws.amazon.com/thread.jspa?threadID=72885