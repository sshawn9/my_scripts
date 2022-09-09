# my_scripts  
This repo handles some scripts and configs for development.  

## environment variables  
Since it is  universally known that `.bashrc` handles some environment variables for shell, we usually add our configs in the end of `.bashrc`, while it is neither elegant nor proper.  
For simplicity, you can just write your own configs in `bash_aliases` under the `$HOME` folder. I will upload my usual configs later.  
What confused me is there are `/etc/profile`, `/etc/bash.bashrc` and so on, what's the mechanism between them? And how ssh pass environment variables?  

## test information  
All the scripts should contain a basic test information, and CI is considering.

## large source file
I konw it can be stored with git-lfs rather than in this repo directly, or get the source code at scripts running time.  
The excuse is: sometimes I have to work with platforms which are not convenient to connect to the network, so I just put them together roughly.  

## what's more
I write these install scripts to make my docker development environment.