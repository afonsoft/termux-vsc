### What is termux?

Termux is an *Android terminal emulator* and **Linux environment** app that works directly with **no rooting** or setup required. A minimal base system is installed automatically - additional packages are available using the *PKG/APT package manager*. More [Here](https://termux.com/)... <br />

### How To install termux?

You can install termux form f-droid. <br />

- Download [Termux](https://f-droid.org/packages/com.termux/) <br />
- Download [Termux:API](https://f-droid.org/packages/com.termux.api/) <br />

More information about installation is [here](https://wiki.termux.com/wiki/Main_Page) <br />

### Preparation

Install `Termux` & `Termux:API` on your phone.

### Installation

After installing both applications above, open `Termux` and follow the steps below -

- Update termux packages and install `git`
```
pkg upgrade && pkg install -y git
```

- Clone this repository
```
git clone --depth=1 https://github.com/afonsoft/termux-vsc.git
```
- Change to cloned directory and run `setup.sh` 
```
cd termux-vsc
chmod +x setup.sh
```
```
./setup.sh
```
> If script `setup.sh` fails during package installation (due to network issues), you can re-execute it again.

### FYI

- If you face any problem or get any error, you can create an issue & i'll try to help.
- Don't Email or DM me to ask how to hack, I ain't a Hacker. 
- Have Fun, Share this repository with your friends.