# KaizenOS

KaizenOS is a voice-enabled assistant designed to streamline your workflow by integrating seamlessly with Apple Shortcuts and built-in Apple tools like [EventKit](https://developer.apple.com/documentation/eventkit). The primary goal of KaizenOS is to abstract backend tasks, such as updating your calendar, so you can focus on what matters most without worrying about the details and manual actions.

To ensure that conversations flow smoothly, Kaizen employs a custom cache memory management system that holds the context of the past 10 queries and responses. This system helps maintain continuity in interactions and ensures that KaizenOS gathers all the necessary context to provide accurate and relevant responses.

Whether it's scheduling events or managing your daily tasks, KaizenOS handles it all in the background. We're also working on expanding these capabilities to include note-taking features with Obsidian and Notion, allowing you to effortlessly capture meeting notes or thoughts on the fly.

If you want to watch the demo of the app, you can download and watch it [HERE](https://github.com/avneetsingh36/kaizenOS/blob/main/KaizenOS-Demo-Video.mov). Below are some pictures of the app:
___

<table align="center">
  <tr>
    <td><img src="https://github.com/user-attachments/assets/a07f63d0-4c9b-4c70-bda4-b9f0ef6f6c54" alt="IMG_6295" width="100%" /></td>
    <td><img src="https://github.com/user-attachments/assets/bac11e0d-7afc-4ad2-996c-e78f97c8de2f" alt="IMG_6298" width="100%" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/064864d3-27ae-4335-9b34-adc286aa2497" alt="IMG_6296" width="100%" /></td>
    <td><img src="https://github.com/user-attachments/assets/2c640f41-246c-4f5f-8692-3c6e11bc5d0b" alt="IMG_6297" width="100%" /></td>
  </tr>
</table>


___

## Features

- **AI Integration**: Powered by GPT-4 and Whisper, KaizenOS enables natural language processing and AI-driven conversations.
- **User Authentication**: Secure sign-up and log-in functionality using Google Firebase Authentication.
- **Dynamic UI**: Built with Swift and SwiftUI, offering a fluid and responsive user experience.
- **Customizable Settings**: Easily accessible settings page to tailor the app to user preferences.
- **Apple and Google Calendar Integration**: Seamlessly integrated with Apple Calendar and Google Calendar to manage events and reminders.
- **Custom Cache Memory Management**: Holds the context of the past 10 queries and responses to ensure smooth conversation flow and accurate context gathering.
- **Work in Progress**: We are actively working on integrating KaizenOS with Notion and Obsidian for enhanced productivity and note-taking capabilities.

## Installation

#### Prerequisites

- **Xcode**: Ensure you have the latest version of Xcode installed on your Mac.
- **CocoaPods**: Install CocoaPods if you haven't already:

  ```bash
  sudo gem install cocoapods
  ```

#### Add Your API Key
Before running the project, you need to add your API key in the ```ViewModel.swift```. Locate the view model file and insert your API key as instructed in the code comments.

#### Run the Project
Open the ```.xcworkspace``` file in Xcode, select your target device or simulator, and run the project.

## Usage

KaizenOS offers a smooth and intuitive experience, allowing users to interact with the system through natural language. Upon launching the app, users can sign up or log in with their credentials. The settings page can be accessed to customize the experience, with ongoing improvements being made to the UI and overall functionality.

## Development

KaizenOS is an ongoing project, and we welcome contributions! Whether it's fixing bugs, improving features, or adding new ones, your help is appreciated.

To Contribute:
- Fork the repository.
- Create a new branch (```git checkout -b feature-branch```).
- Make your changes.
- Commit your changes (```git commit -m "Add some feature"```).
- Push to the branch (```git push origin feature-branch```).
- Create a new Pull Request.

## License

KaizenOS is licensed under the MIT License. See the LICENSE file for more details.
