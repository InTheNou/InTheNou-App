# InTheNou-App
  
## Develop
You will first need to install Flutter on your computer. To do this follow the [Official Instructions](https://flutter.dev/docs/get-started/install) for the platform you are on.
Run `flutter doctor` in a terminal to make sure the setup is complete.
Clone or download the repository to your computer.


### Run the App from Source
Make sure your device has Developer Mode and USB debugging turned on. If not then follow the setup outlined in Install the App. 

Open the root of the project in a terminal and run 
`flutter deivces`

A list of devices connected will show up with entries such as
> SM N950U • XXXXXXXXXXXXXXX • android-arm64 • Android 9 (API 28)

Now copy the string of characters where the Xs are and run one of the following commands.
For Debug Mode
    ```sh
    $ flutter run -d XXXXXXXXXXXX
    ```
For Release Mode
    ```sh
    $ flutter run --release  -d XXXXXXXXXXXX
    ```
For Profile Mode
    ```sh
    $ flutter run --profile -d XXXXXXXXXXXX
    ```

Substituting the Xs for the characters copied

For building the app you will need 'key.jks' and 'keystore.properties' that are not in this
repository for security reasons. Your Android Directory should like like so:
> /android/
    key.jks
    keystore.properties
    ...

### Build the App from Source

Open the root of the project in a terminal and run
    ```sh
    $ flutter build apk
    ```
This will build the Release version of the App.
  
## Install The App  APK
  
You will need ADB on your computer and Developer Mode enabled on your phone as well as USB debugging  
 turned on inside the Developer Options in your phone.  
To do this you can follow this tutorial for the platform you use the [Tutorial by XDA Developers](https://www.xda-developers.com/install-adb-windows-macos-linux/)
  
Once that is done, copy the app-release.apk file to the same folder ADB was installed.  
  
Connect your phone to your computer and run the following command:
    ```sh
    $ adb install app-release.apk
    ```

Upon finishing, ADB will print out "Success" and the app will be installed on the phone.
