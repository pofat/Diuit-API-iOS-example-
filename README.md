# Diuit API Sample Code

This is a basic example to demonstrate how to integrate with Diuit Messaging API framework. For more detail, please check our [API document](http://api.diuit.com/doc/en/guideline.html).


## Getting started

### Building Diuit API Example APP

To build this app, you need:

1. [Xcode](https://developer.apple.com/xcode/) - Available on the [App Store](http://itunes.apple.com/us/app/xcode/id497799835).
2. [CocoaPods](http://cocoapods.org/) - The dependency manager for Cocoa projects. If you don't have it, install by executing `$ sudo gem install cocoapods` in your terminal.

**Note:** We currently do not support any beta version of CocoaPods 1.0.0 due to a [breaking change](https://github.com/CocoaPods/CocoaPods/issues/4950#issuecomment-196289770). Please use Cocoapods 0.39.x.

### Work with the server

You can either use our demo server to experience all features in a second or use your own server. The main goal of the server is to provide an authentication for your device and response a corresponding session token, which is from Diuit API server.

* If you want to try with our demo server:
	1. Please [contact us](mailto:pofattseng@diuit.com) to get demo server address.
	2. Replace value of `_serverUrl` in Utility.swift with our demo server url.
	3. Sign in two account on two different devices (or simulators).
	4. Create a new chat room or join any existed room.
	5. Happy chatting.
	
* If you'd like to use your own server:
	1. Your server must have a 'signin' API
	2. After your server authenticate the device sending the 'signin' request, it has to request a session token from Diuit API server.
	3. Pass this token to your device, so that device can do authentication with Diuit API
	4. Replace value of `_serverUrl` in Utility.swift with your server url.
	5. Replace the closure of `Utility.doPostWith` in LoginVC.swift or SignUpVC.swift with your handlers for sign in/sign up response from your server.
	6. Sign in/up your account on two different devices (or simulators).
	4. Create a new chat room or join any existed room.
	7. Start chatting.


## Usage of Diuit API

* Find comment blocks initiated with "[Diuit API]" in this sample code. Those demonstrate how to integrate with Diuit API.

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

This app was developed by Diuit team. If you have any technical questions or concerns about this project feel free to [contact us](mailto:benchang@diuit.com).



