# Diuit API Sample Code

This is a basic example to demonstrate how to integrate with Diuit Messaging API framework. For more detail, please check our [API document](http://api.diuit.com/doc/en/guideline.html).

## Install

Install all required frameworks via Cocoapods by executing command: `pod install`

## Getting started

* Replace val of `_serverUrl` in Utility.swift with your server url.
* Replace the closure of `Utility.doPostWith` in LoginVC.swift or SignUpVC.swift with your handlers for sign in/sign up response from your server.
* Sign in/up your account on two different devices (or simulators).
* Then you can enter any chat room and start sending messages.

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



