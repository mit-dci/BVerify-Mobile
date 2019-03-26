# BVerify-Mobile
This repository contains mobile clients for b_verify to independently verify witnessed statements.

## iOS

The [iOS](iOS/) version is built in Objective-C. Before you can build it, you will have to build the Mobile.framework, which is built from the [go-bverify](https://github.com/mit-dci/go-bverify/tree/master/mobile) mobile folder (you need the [gomobile bind](https://godoc.org/golang.org/x/mobile/cmd/gomobile) command). Once the Mobile.framework is in place you can build the app and run it on your phone.
