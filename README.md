copycom2deb
===========

Disclaimer
----------
This software is not an official package or installer from Barracuda Networks.
They are not responsible for anything that will happen when you use this installer.
Although what it does is quite simple, it might break, break your system or kill
your pet space hamster. You have been warned, use it at your own risk.

What's this?
------------
It's a simple script to download and package the Linux client agent for Barracuda Networks
cloud storage solution "[Copy]". It's a viable alternative for Dropbox IMHO.
I use Ubuntu/Debian on my machines, but the Linux installer is a simple tgz file.
To be able to install the agent with a package manager, I wrote a little script to do the following:

* Install the tools needed to create Debian packages
* Download current version of the [Copy] client agent
* Create a Debian package of the downloaded client agent

Installation
------------
Clone copycom2deb git repository:

    git clone https://github.com/neovatar/copycom2deb.git

Creating a package
------------------
Change into the cloned repository and start the script:

    ./build.sh
    
This will ask for a maintainer name and email, both of which will be included in the
final package. Now the script will run apt-get to install the required tools to build
Debian packages. It will use sudo, so you will have to authenticate. Then the script
will download the lastest version of the [Copy] agent and wrap it up into a Debian package.
You will find the resulting package in the build subdirectory.

Install a package
-----------------
Change to the newly created build directory:

    cd build
    
Install the package by running (replace version and arch):

    sudo dpkg -i copy-agent_1.28.0657_amd64.deb
    
The [Copy] agent will be installed in

    /opt/copy-agent
    
The binaries will be linked to /usr/bin, e.g.

    /usr/bin/CopyAgent -> /opt/copy-agent/CopyAgent

Set package creation options
----------------------------
You can control packaging options by setting environment variables like this:

    MAINTAINER="Tom" EMAIL="tom@tomshome" ./build.sh


The following environment variables are supported:

<table>
  <tr>
    <td>MAINTAINER</td><td>Set maintainer name</td>
  </tr>
  <tr>
    <td>EMAIL</td><td>Set maintainer email</td>
  </tr>
</table> 

[Copy]: http://copy.com/
