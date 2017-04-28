# BugReporter

[![CI Status](http://img.shields.io/travis/eaceto/BugReporter.svg?style=flat)](https://travis-ci.org/eaceto/BugReporter)
[![Version](https://img.shields.io/cocoapods/v/BugReporter.svg?style=flat)](http://cocoapods.org/pods/BugReporter)
[![License](https://img.shields.io/cocoapods/l/BugReporter.svg?style=flat)](http://cocoapods.org/pods/BugReporter)
[![Platform](https://img.shields.io/cocoapods/p/BugReporter.svg?style=flat)](http://cocoapods.org/pods/BugReporter)
[![Twitter](https://img.shields.io/badge/twitter-@eaceto-blue.svg?style=flat)](http://twitter.com/eaceto)

BugReporter is a simple and elegant bug reporting tool for you apps.

- [Features](#features)
- [How to setup](#how-to-setup)
- [What BugReporter is not](#what-bugreporter-is-not)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
- [Author](#author)
- [License](#license)

## Features

- [x] Detect 'take screenshot' event and fire a report
- [x] Create a report with information about the device and the application
- [x] Send report using email as channel
- [x] Send report using UIActivityViewController as channel
- [x] Load configuration from a property file (plist)
- [x] Notify reporting life cycle
- [ ] Detect shake gesture and fire a report
- [ ] Attach multiple images to a report
- [ ] Save report into file system if cannot be sent
- [ ] Send report to a backend

## What BugReporter is not

- BugReporter **is not** a crash reporting tool (like Crashlytics).
- BugReporter **will not** take screenshots of your app unless the user triggers a report event.

## How to setup

Include a file named *BugReporterSettings.plist* inside your project. The content of this property file should have at least one property called **applicationId** with a non-empty string value. This property will be used in future versions when integrating with a backend.

### reportsEMail
This property lets you specify a list of emails, used as default addresses when sending a report through email.

### Example file

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    	<key>applicationId</key>
    	<string>YOUR-APP-ID</string>
    	<key>reportEMails</key>
    	<array>
    		<string>developer_1_email@your-company.com</string>
            <string>developer_2_email@your-company.com</string>
            <string>qa_guy@your-company.com</string>        
    	</array>
    </dict>
    </plist>


## Requirements

- iOS 8.0+
- Xcode 8.1+
- Swift 3.0+

## Communication

- If you **need help**, write me an e-mail
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

BugReporter is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BugReporter"
```

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Author

Ezequiel Aceto, ezequiel.aceto (at) gmail.com

## License

BugReporter is available under the MIT license. See the LICENSE file for more info.
