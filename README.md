# Termux_XFCE

Sets up a termux XFCE desktop and a Debian proot install and installs some additional software like Brave Web Browser, Firefox, Libreoffice, Audacious, Webcord, FreeTube (YouTube Client) and a few others.

You only need to pick your username and follow the prompts to create a password for proot user. This will take roughly 7.5GB of storage space. Please note, this can be a lengthy process.

This setup uses Termux-X11, the termux-x11 server will be installed and you will be prompted to allow termux to install the Android APK. 

This is is how I personally use Termux on my Galaxy Fold 3, script was created mainly for personal use but also for others if they wanted to try out my setup. This is my daily driver used with a 15 inch Lepow portable monitor and bluetooth keyboard and mouse.

&nbsp;
# Starting the desktop

During install you will recieve a popup to allow installs from termux, this will open the APK for the Termux-X11 android app. While you do not have to allow installs from termux, you will still need to install manually by using a file browser and finding the APK in your downloads folder. 
  

After install you will need to exit termux using the command ```exit```
  
Once you restart termux you can use the command ```start``` 
  
This will start the termux-x11 server, XFCE4 desktop and open the Termux-X11 app right into the desktop. 

To enter the Debian proot install from terminal use the command ```debian```

Also note, you do not need to set display in Debian proot as it is already set. This means you can use the terminal to start any GUI application and it will startup.

&nbsp;

# cp2menu

A companion script for this setup to make it easier to add apps installed into debian proot to be added to the termux xfce menu. 
I have noticed an issue with some things not wanting to show in the menu even with this script, those .desktop files will need to be manually edited by the user, however once moved you can also created a desktop launcher normally for that app and it will work as expected.

&nbsp;

# Backup & Restore

This script will back up and restore the installed FreeTube, Vivaldi, and WebCord .config directories. 

&nbsp;

# Kill Termux X11

This script will shut down your session, you will have to manually close the Android apps

&nbsp;

# Install

To install run this command in termux

```
termux-change-repo && curl -sL https://raw.githubusercontent.com/rafiazman/Termux_XFCE/develop/setup2.sh | bash
```

&nbsp;

There is also a lite version without all the extra apps

```
curl -sL https://raw.githubusercontent.com/rafiazman/Termux_XFCE/main/setup_lite.sh | bash
```

&nbsp;

![Desktop Screenshot](Desktop.png)
