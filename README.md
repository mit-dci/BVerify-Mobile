# BVerify-Mobile
This repository contains mobile clients for b_verify to independently verify witnessed statements.

## iOS

The [iOS](iOS/) version is built in Objective-C. Before you can build it, you will have to build the Mobile.framework, which is built from the [go-bverify](https://github.com/mit-dci/go-bverify/tree/master/mobile) mobile folder (you need the [`gomobile bind -target=ios`](https://godoc.org/golang.org/x/mobile/cmd/gomobile) command). Once the Mobile.framework is in place you can build the app and run it on your phone.

## Android

The [Android](Android/) version is built in Java. As with iOS, you need to build the mobile framework (`mobile.aar`), which is built from the [go-bverify](https://github.com/mit-dci/go-bverify/tree/master/mobile) mobile folder (you need the [`gomobile bind -target=android`](https://godoc.org/golang.org/x/mobile/cmd/gomobile) command). Once the mobile.aar is built, you can place it in the correct location (the [Android/mobile](Android/mobile) folder) and build the Android app using Android Studio.