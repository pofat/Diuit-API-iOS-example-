# Diuit API Sample Code

This sample code will help you get started using Diuit Messaging API framework without writing a line of code. After downloading the file, follow the instruction below and you will get to experience Diuit Messaging API. For the technical details, please refer to our [API document](http://api.diuit.com/doc/en/guideline.html).


## Getting started

### Building Diuit API Demo APP

To build this demo app, you will need:

1. [Xcode](https://developer.apple.com/xcode/) - Available on the [App Store](http://itunes.apple.com/us/app/xcode/id497799835). Please also make sure that your Xcode is up to date.
2. [CocoaPods](http://cocoapods.org/) - The dependency manager for Cocoa projects. If you don't have it, install it by executing `$ sudo gem install cocoapods` in your terminal.

**Note:** We currently do not support any beta version of CocoaPods 1.0.0 due to a [breaking change](https://github.com/CocoaPods/CocoaPods/issues/4950#issuecomment-196289770). Please use Cocoapods 0.39.x.

### Set up server
For users who are already running your own servers, we provide a step-by-step guide to tell you how to let the server authenticate your device and response a session token from Diuit API server. For those who don't have a running server yet, we also provide a demo server. Please refer to the following instruction. 

* If you prefer using our demo server:
 	1. Please download the entire sample code repository.
 	2. Execute `pod install` to install required package in the project folder.
	2. [Sign up](http://developer.diuit.com/login) and [contact us](mailto:pofattseng@diuit.com) to get the demo server address.
	3. Replace value of `_serverUrl` in Utility.swift with the demo server url we provide you in step (2).
	4. Sign in two account on two different devices (or simulators).
	5. Create a new chat room or join any existing room.
	6. Start chatting.
	
* If you'd like to use your own server:
	1. Your server must have a 'sign-in' API
	2. After your server authenticate the device sending the 'sign-in' request, it has to request a session token from Diuit API server.
	3. Pass this token to your device, so that device can do authentication with Diuit API server
	4. Execute `pod install` to install required package in the project folder.
	4. Replace value of `_serverUrl` in Utility.swift with your server url.
	5. Replace the closure of `Utility.doPostWith` in LoginVC.swift or SignUpVC.swift with your handlers for sign in/sign up response from your server.
	6. Sign in/up your account on two different devices (or simulators).
	4. Create a new chat room or join an existing one.
	7. Start chatting.


## Usage of Diuit API

* In the sample code you'll find comment blocks initiated with "[Diuit API]", which explain how to integrate with Diuit API.

	```swift
	/**
    	[Diuit API] Create a new chat room with given array of user serials
     */
    DUMessaging.createChatroomWith(userSerials) { error, chat in
    	guard let _:DUChat = chat where error == nil else {
            print("Create chat error : \(error!.localizedDescription)")
            return
        }
    }
	```

## Contact

This app was developed by Diuit team. If you have any technical questions or concerns about this project feel free to [contact us](mailto:benchang@diuit.com) or join our [Slack channel](http://slack.diuit.com/).